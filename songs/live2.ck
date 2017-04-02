
include(song_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)


define(SEQ_COUNT, 2);
define(OUT_DEVICE_COUNT, 4);
define(ROW_COUNT, 4);


fun ModuckP makeRecBufs(int count){
  def(recBlocker, mk(Blocker));
  def(rit, ritmo(false
    ,[P_GoTo, P_Set, P_Trigger]
    ,[ mk(Buffer)
      ,mk(Buffer)
      ,mk(Buffer)
      ,mk(Buffer)
  ]));
  def(root, mk(Repeater, Util.concatStrings([rit.getSourceTags(), [P_GoTo, P_Gate, "rec"]])));


  root => recBlocker.fromTo("rec", P_Gate).c;
  root => recBlocker.from(P_Gate).c;
  root => rit
    .listen([P_GoTo])
    .listen(rit.getSourceTags())
    .fromTo(P_Trigger, P_Clock).c;
  recBlocker => rit.to("active_"+P_Set).c;

  def(out, mk(Repeater, [P_Trigger]));
  root => out.fromTo(P_Gate, P_Trigger).c;

  rit => out.c;

  for(0=>int i;i<count;++i){
    rit
      => MUtil.onlyLow().from(recv(""+i)).c
      => out.c;
  }

  return mk(Wrapper, root, out);
}


fun ModuckP makeTogglingOuts(ModuckP source, int outCount){
  [P_Trigger] @=> string rootTags[];
  string outTags[0];
  for(0=>int i;i<outCount;++i){
    rootTags << "toggleOut"+i;
    outTags << "outActive"+i;
    outTags << ""+i;
  }
  def(root, mk(Repeater, rootTags));
  def(out, mk(Repeater, outTags));

  ModuckP outBlockers[outCount];
  for(0=>int i;i<outCount;++i){
    def(blocker, mk(Blocker, true));
    blocker @=> outBlockers[i];
    def(toggler, mk(Toggler));
    toggler => blocker.fromTo("1", P_Gate).c;
    root => toggler.fromTo("toggleOut"+i, P_Toggle).c;
    toggler => mk(Inverter, 0).c => out.to("outActive"+i).c;
    source
      => blocker.c
      => out.to(""+i).c
    ;
  }

  return mk(Wrapper, root, out);
}


def(metronome, mk(Repeater));
Runner.masterClock
  => mk(PulseDiv, B).c
  => metronome.c
;


def(keysIn, mk(Repeater));
def(bufRestarter, mk(Repeater));
ModuckP outs[0];
ModuckP bufs[0];
def(inRouter, mk(Router, 0));
def(recToggle,
  mk(Repeater)
  => mk(Toggler).to(P_Toggle).c
  => mk(Inverter, 0).c
);
def(bufHoldToggle, mk(Repeater));
def(_holdToggler, mk(Toggler));
bufHoldToggle => _holdToggler.to(P_Toggle).c;
keysIn => inRouter.c;
for(0=>int i;i<ROW_COUNT;++i){
  makeRecBufs(SEQ_COUNT) @=> ModuckP b;
  Runner.masterClock => b.c;
  bufs << b;
  _holdToggler => b.to(P_Hold).c;
  inRouter => b.fromTo(""+i, P_Gate).c;
  bufRestarter => mk(TrigValue, 0).c => b.to(P_GoTo).c;
  def(out, makeTogglingOuts(b, OUT_DEVICE_COUNT));
  outs << out;

  recToggle => b.to("rec").c;

  Runner.masterClock => out.c;
}


Runner.masterClock
  => mk(PulseDiv, Bar).c
  => bufRestarter.c
;


// OUTPUTS

def(lpOut, mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false));
def(circuit1, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));
def(circuit2, mk(NoteOut, MIDI_OUT_CIRCUIT, 1, false));

for(0=>int outInd;outInd<outs.size();++outInd){
  outs[outInd]
    .b(circuit1.from("0"))
    .b(circuit2.from("1"))
  ;
}


// DEVICES

def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));


launchpad => bufHoldToggle.from("note112").c;
mkToggleIndicator(_holdToggler, P_Active, 112, false);
// MAPPINGS

/* nanoktrl => mk(Printer, "nanoktrl note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c; */
launchpad => mk(Printer, "lp note").from("note").c;
/* launchpad => mk(Printer, "lp cc").from("cc").c; */
oxygen => mk(Printer, "oxygen cc").from("cc").c;
oxygen => mk(Printer, "oxygen note").from("note").c;
oxygen => lpOut.from("note").c;


oxygen => keysIn.from("note").c;


for(0=>int outInd;outInd<outs.size();++outInd){
  launchpad
    =>mk(Bigger,0).from("cc"+(104+outInd)).c
    =>mk(TrigValue,outInd).c
    =>inRouter.to("index").c
  ;
  mkToggleIndicator(
  inRouter
  =>MUtil.onlyHigh().from(recv("index")).c
  =>mk(Processor,Eq.make(outInd)).c
  =>mk(TrigValue,outInd).c
  ,P_Trigger,104+outInd,true);
}


fun void makeOutsUIRow(int rowId){
  for(0=>int i;i<SEQ_COUNT;++i){
    launchpad
      =>mk(TrigValue,i).from("note"+(rowId*16+i)).c
      =>bufs[rowId].to(""+i).c
    ;
  }

  launchpad=>outs[rowId].fromTo("note"+(rowId*16+4),"toggleOut0").c;
  launchpad=>outs[rowId].fromTo("note"+(rowId*16+5),"toggleOut1").c;
  launchpad=>outs[rowId].fromTo("note"+(rowId*16+6),"toggleOut2").c;
  launchpad=>outs[rowId].fromTo("note"+(rowId*16+7),"toggleOut3").c;


  mkToggleIndicator(outs[rowId],"outActive0",rowId*16+4, false);
  mkToggleIndicator(outs[rowId],"outActive1",rowId*16+5, false);
  mkToggleIndicator(outs[rowId],"outActive2",rowId*16+6, false);
  mkToggleIndicator(outs[rowId],"outActive3",rowId*16+7, false);

}


launchpad
  => mk(Bigger, 0).from("cc111").c
  => recToggle.c
;
mkToggleIndicator(bufs[0], recv("rec"), 111, true);

for(0=>int i;i<ROW_COUNT;++i){
  makeOutsUIRow(i);
}


fun ModuckP mkToggleIndicator(ModuckP src, string tag,int noteNum, int isCC){
  def(indicator, mk(TrigValue, noteNum) => mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false).set("isCC", isCC).c);
  src => indicator.from(tag).c;
  return indicator;
}


// Send launchpad reset message
MidiMsg msg;
MidiOut midOut;
midOut.open(MIDI_IN_LAUNCHPAD) => int succ;
176 => msg.data1;
midOut.send(msg);

Runner.setPlaying(1);
Util.runForever();
