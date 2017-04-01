
include(song_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)


define(SEQ_COUNT, 2);
define(OUT_DEVICE_COUNT, 2);
define(ROW_COUNT, 4);

// TODO: this is just a bad special case of Ritmo..
fun ModuckP makeRecBufs(int count){
  def(root, mk(Repeater, [P_Trigger, P_Reset, P_GoTo, P_Gate, "index", "rec"]));
  def(out, mk(Repeater, [P_Trigger]));
  def(playRouter, mk(Router, 0));
  def(recRouter, mk(Router, 0));
  def(recBlocker, mk(Blocker));
  root
    .b(playRouter.listen(["index", P_Trigger]))
    .b(recRouter.listen("index"))
    .b(recBlocker.fromTo("rec", P_Gate))
    .b(out.fromTo(P_Gate, P_Trigger)) // Play notes that we receive, even if not recording
  ;
  root => recBlocker.from(P_Gate).c;

  ModuckP bufs[count];
  for(0=>int i;i<count;++i){
    mk(Buffer) @=> ModuckP buf;
    buf @=> bufs[i];
    root => buf.listen([P_Reset,P_GoTo]).c;
    playRouter
      .b(buf.fromTo(recv("index"), P_Reset))
      .b((buf => out.c).from(""+i));
    recRouter
      => recBlocker.from(""+i).c
      => buf.to(P_Set).c;
    buf => out.c;
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
def(inRouter, mk(Router, 0, false));
def(recToggle,
  mk(Repeater)
  => mk(Toggler).to(P_Toggle).c
  => mk(Inverter, 0).c
);
keysIn => inRouter.c;
for(0=>int i;i<ROW_COUNT;++i){
  makeRecBufs(SEQ_COUNT) @=> ModuckP b;
  Runner.masterClock => b.c;
  bufs << b;
  inRouter => b.fromTo(""+i, P_Gate).c;
  bufRestarter => mk(Value, 0).c => b.to(P_GoTo).c;
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
    => mk(Bigger, 0).from("cc"+(104+outInd)).c
    => mk(TrigValue, outInd).c
    => inRouter.to("index").c
  ;
  mkToggleIndicator(
    inRouter
    => MUtil.onlyHigh().from(recv("index")).c
    => mk(Processor, Eq.make(outInd)).c
    => mk(TrigValue, outInd).c
    ,P_Trigger,104+outInd, true);
}


fun void makeOutsUIRow(int rowId){
  for(0=>int i;i<SEQ_COUNT;++i){
    launchpad
      => mk(TrigValue, i).from("note"+(rowId*16+i)).c
      => bufs[rowId].to("index").c
    ;
  }

  launchpad=>outs[rowId].fromTo("note"+(rowId*16+6),"toggleOut0").c;
  launchpad=>outs[rowId].fromTo("note"+(rowId*16+7),"toggleOut1").c;


  mkToggleIndicator(outs[rowId],"outActive0",rowId*16+6, false);
  mkToggleIndicator(outs[rowId],"outActive1",rowId*16+7, false);

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
