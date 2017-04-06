
include(song_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)


define(SEQ_COUNT, 4);
define(OUT_DEVICE_COUNT, 4);
define(ROW_COUNT, 2);


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
  root => recBlocker.fromTo(P_Gate, P_Trigger).c;
  root => rit
    .listen([P_GoTo])
    .listen(rit.getSourceTags())
    .fromTo(P_Trigger, P_Clock).c;
  recBlocker => rit.to("active_"+P_Set).c;

  [P_Trigger] @=> string outTags[];
  for(0=>int i;i<count;++i){
    outTags << "active_"+i;
  }
  def(out, mk(Repeater, outTags));
  root => out.fromTo(P_Gate, P_Trigger).c;

  rit => out.c;

  for(0=>int i;i<count;++i){
    rit
      => MBUtil.onlyLow().from(recv(""+i)).c
      => out.c;
    rit => out.listen("active_"+i).c;
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
    def(toggler, mk(Toggler, false));
    toggler => blocker.to(P_Gate).c;
    root => toggler.fromTo("toggleOut"+i, P_Toggle).c;
    toggler => out.to("outActive"+i).c;
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
  => mk(SampleHold, 100::ms).c
  => metronome.c
;


def(keysIn, mk(Repeater));
def(bufRestarter, mk(Repeater));
ModuckP outs[0];
ModuckP bufs[0];
def(inRouter, mk(Router, 0));
def(recToggle,
  mk(Repeater)
  => mk(Toggler, false).to(P_Toggle).c
);
def(bufHoldToggle, mk(Repeater));
def(_holdToggler, mk(Toggler));
bufHoldToggle => _holdToggler.to(P_Toggle).c;
keysIn => inRouter.c;
for(0=>int i;i<ROW_COUNT;++i){
  MUtil.gatesToToggles(makeRecBufs(SEQ_COUNT), Util.numberedStrings("", Util.range(0,SEQ_COUNT-1)), false) @=> ModuckP b;
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

MidiOut launchpadDeviceOut;
<<<"Opening launchpad out">>>;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);
MidiOut circuitDeviceOut;
<<<"Opening circuit out">>>;
circuitDeviceOut.open(MIDI_OUT_CIRCUIT);

def(circuit1, mk(NoteOut, circuitDeviceOut, 0, false));
def(circuit2, mk(NoteOut, circuitDeviceOut, 1, false));

for(0=>int outInd;outInd<outs.size();++outInd){
  outs[outInd]
    .b(circuit1.from("0"))
    .b(circuit2.from("1"))
  ;
}


// DEVICES

<<<"Opening launchpad in">>>;
def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
<<<"Opening oxygen in">>>;
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));


launchpad => bufHoldToggle.from("note112").c;
mkIndicator(_holdToggler, P_Default, 112, false);


// MAPPINGS

/* nanoktrl => mk(Printer, "nanoktrl note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c; */
launchpad => mk(Printer, "lp note").from("note").c;
/* launchpad => mk(Printer, "lp cc").from("cc").c; */
oxygen => mk(Printer, "oxygen cc").from("cc").c;
oxygen => mk(Printer, "oxygen note").from("note").c;


oxygen => keysIn.from("note").c;


for(0=>int outInd;outInd<outs.size();++outInd){
  launchpad
    =>mk(Bigger,0).from("note"+(8+outInd*16)).c
    =>mk(TrigValue,outInd).c
    =>inRouter.to("index").c
  ;
  mkIndicator(
    inRouter
    =>MBUtil.onlyHigh().from(recv("index")).c
    =>mk(Processor, Eq.make(outInd)).c
    =>mk(TrigValue, outInd).c
  ,P_Trigger,8+outInd*16,false);
}


for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
  for(0=>int patternInd;patternInd<SEQ_COUNT;++patternInd){
    bufs[rowInd]
      => mk(TrigValue, rowInd*16+patternInd).from("active_"+patternInd).c
      => mk(NoteOut, launchpadDeviceOut, 0, false).c;
  }
}

fun void makeOutsUIRow(int rowId){
  for(0=>int i;i<SEQ_COUNT;++i){
    launchpad
      =>mk(TrigValue,i).from("note"+(rowId*16+i)).c
      =>bufs[rowId].to(""+i).c
    ;
  }

  for(0=>int outputId;outputId<OUT_DEVICE_COUNT;++outputId){
    launchpad=>outs[rowId].fromTo("note"+(rowId*16+4+outputId),"toggleOut"+outputId).c;
    mkIndicator(outs[rowId],"outActive"+outputId,rowId*16+4+outputId, false);
  }
}

launchpad
  => mk(Bigger, 0).from("cc111").c
  => recToggle.c
;
mkIndicator(bufs[0], recv("rec"), 111, true);

for(0=>int i;i<ROW_COUNT;++i){
  makeOutsUIRow(i);
}


fun ModuckP mkIndicator(ModuckP src, string tag,int noteNum, int isCC){
  def(indicator, mk(TrigValue, noteNum) => mk(NoteOut, launchpadDeviceOut, 0, false).set("isCC", isCC).set("velocity", 100).c);
  src => indicator.from(tag).c;
  return indicator;
}


metronome
  => mk(TrigValue, 7*16).c
  => mk(NoteOut, launchpadDeviceOut, 0, false).c
;



// Send launchpad reset message
MidiMsg msg;
176 => msg.data1;
launchpadDeviceOut.send(msg);

Runner.setPlaying(1);
Util.runForever();
