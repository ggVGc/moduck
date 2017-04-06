include(song_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)

define(SEQ_COUNT, 4);
define(OUT_DEVICE_COUNT, 4);
define(ROW_COUNT, 2);



fun ModuckP makeRecBufs(int count){
  def(recBlocker, mk(Blocker));
  def(rit, ritmo(false
    ,[P_GoTo, P_Set]
    ,[ mk(Buffer)
      ,mk(Buffer)
      ,mk(Buffer)
      ,mk(Buffer)
  ]));


  def(root, mk(Repeater, Util.concatStrings(
      [rit.getSourceTags(), [P_GoTo, P_Gate, "rec", "length"]])));

  root
    .b(recBlocker
      .fromTo("rec", P_Gate)
      .fromTo(P_Gate, P_Trigger)
    ).b(rit
      .listen(P_GoTo)
      .listen(rit.getSourceTags())
    );
  recBlocker => rit.to("active_"+P_Set).c;

  def(restarter, mk(Repeater));

  restarter
    => mk(TrigValue, 0).c
    => rit.to(P_GoTo).c
  ;

  root
    => frm(P_Clock).c
    => (mk(PulseDiv, Bar).hook(root.fromTo("length", "divisor")) ).c
    => restarter.c
  ;

  [P_Trigger] @=> string outTags[];
  for(0=>int i;i<count;++i){
    outTags << "active_"+i;
  }

  def(out, mk(Repeater, outTags));

  root => frm(P_Gate).to(out, P_Trigger).c;
  rit => out.c;

  for(0=>int i;i<count;++i){
    // Send out any low signals,
    // to prevent hanging notes when disabling buffers
    rit
      => frm(recv(""+i)).c
      => MBUtil.onlyLow().c
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
    def(toggler, mk(Toggler, false));

    blocker @=> outBlockers[i];

    root => frm("toggleOut"+i).to(toggler, P_Toggle).c;

    toggler 
      .b(blocker.to(P_Gate))
      .b(out.to("outActive"+i))
    ;
    source
      => blocker.c
      => out.to(""+i).c
    ;
  }

  return mk(Wrapper, root, out);
}


def(keysIn, mk(Repeater));
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
  inRouter => frm(""+i).to(b, P_Gate).c;
  def(out, makeTogglingOuts(b, OUT_DEVICE_COUNT));
  outs << out;

  recToggle => b.to("rec").c;

  Runner.masterClock => out.c;
}



def(metronome, mk(Repeater));
Runner.masterClock
  => mk(PulseDiv, B).c
  => mk(SampleHold, 100::ms).c
  => metronome.c
;



// OUTPUTS

MidiOut launchpadDeviceOut;
<<<"Opening launchpad out">>>;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);
MidiOut circuitDeviceOut;
<<<"Opening circuit out">>>;
circuitDeviceOut.open(MIDI_OUT_CIRCUIT);

// Send launchpad reset message
MidiMsg msg;
176 => msg.data1;
launchpadDeviceOut.send(msg);

def(circuit1, mk(NoteOut, circuitDeviceOut, 0, false));
def(circuit2, mk(NoteOut, circuitDeviceOut, 1, false));

for(0=>int outInd;outInd<outs.size();++outInd){
  outs[outInd]
    .b(frm("0").to(circuit1))
    .b(frm("1").to(circuit2))
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

setupOutputSelection();
setupActiveBufsIndicators();

launchpad
  => mk(Bigger, 0).from("cc111").c
  => recToggle.c ;

mkIndicator(bufs[0], recv("rec"), 111, true);

for(0=>int i;i<ROW_COUNT;++i){
  makeOutsUIRow(i);
}



fun void setupOutputSelection(){
  for(0=>int outInd;outInd<outs.size();++outInd){
    // Select outputs with side buttons
    8+outInd*16 => int ind;
    launchpad
      => mk(Bigger,0).from("note"+ind).c
      => mk(TrigValue,outInd).c
      => inRouter.to("index").c
    ;

    mkIndicator(
      inRouter
      => MBUtil.onlyHigh().from(recv("index")).c
      => mk(Processor, Eq.make(outInd)).c
      => mk(TrigValue, outInd).c
    ,P_Trigger, ind, false);
  }
}


fun void setupActiveBufsIndicators(){
  for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
    for(0=>int bufId;bufId<SEQ_COUNT;++bufId){
      bufs[rowInd]
        => mk(TrigValue, rowInd*16+bufId).from("active_"+bufId).c
        => mk(NoteOut, launchpadDeviceOut, 0, false).c;
    }
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

fun ModuckP mkIndicator(ModuckP src, string tag,int noteNum, int isCC){
  def(indicator, mk(TrigValue, noteNum) => mk(NoteOut, launchpadDeviceOut, 0, false).set("isCC", isCC).set("velocity", 100).c);
  src => indicator.from(tag).c;
  return indicator;
}


/* 
 metronome
   => mk(TrigValue, 7*16).c
   => mk(NoteOut, launchpadDeviceOut, 0, false).c
 ;
 */

Runner.setPlaying(1);
inRouter.doHandle("index", IntRef.make(0));
Util.runForever();
