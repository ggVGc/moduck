include(song_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)
include(parts/rec_buf_ui.ck)

/* define(SEQ_COUNT, 1); */
define(OUT_DEVICE_COUNT, 4);
define(ROW_COUNT, 8);


Runner.setPlaying(1);


fun ModuckP makeTogglingOuts(int outCount){
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
    root
      => frm(P_Trigger).c
      => blocker.c
      => out.to(i).c
    ;
  }

  return mk(Wrapper, root, out);
}


def(keysIn, mk(Repeater));
ModuckP outs[0];
ModuckP bufs[0];
ModuckP holdToggles[];
def(inRouter, mk(Router, 0));

keysIn => inRouter.c;

for(0=>int i;i<ROW_COUNT;++i){
  10::ms => now; // Keep JACK happy
  def(b, mk(RecBuf, Bar));
  def(bufOut, mk(Repeater));
  def(noteHolder, mk(Value, null));
  def(holdTog, mk(Toggler));

  Runner.masterClock => b.to(P_Clock).c;

  inRouter => frm(i).to(b, P_Set).c;

  b
    => iff(noteHolder, recv(P_Set))
      .then(noteHolder)
      .els(mk(Repeater)).c
    => bufOut.c;

  b
    => MBUtil.onlyLow().c
    => bufOut.c;


  /* samp => now; */
  /* noteHolder.doHandle(P_Set, IntRef.make(70)); */

  def(out, makeTogglingOuts(OUT_DEVICE_COUNT).hook(bufOut.listen(P_Trigger)));

  bufs << b;
  outs << out;
}



def(metronome, mk(Repeater));
Runner.masterClock
  => mk(PulseDiv, B).c
  => mk(SampleHold, 100::ms).c
  => metronome.c
;





// DEVICES

<<<"Opening launchpad in">>>;
def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
<<<"Opening oxygen in">>>;
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));

MidiOut launchpadDeviceOut;
<<<"Opening launchpad out">>>;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);
MidiOut circuitDeviceOut;
<<<"Opening circuit out">>>;
circuitDeviceOut.open(MIDI_OUT_CIRCUIT);

def(lpOut, mk(NoteOut, launchpadDeviceOut, 0));


def(circuit1, mk(NoteOut, circuitDeviceOut, 0));
def(circuit2, mk(NoteOut, circuitDeviceOut, 1));

// OUTPUTS


for(0=>int outInd;outInd<outs.size();++outInd){
  outs[outInd]
    .b(frm(0).to(circuit1))
    .b(frm(1).to(circuit2))
  ;
}

// MAPPINGS

oxygen => keysIn.from("note").c;

setupOutputSelection();


for(0=>int rowId;rowId<ROW_COUNT;++rowId){
  makeOutsUIRow(rowId);

  def(ui, recBufUI(bufs[rowId]));
  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => ui.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16)).to(ui, P_Trigger));

  ui => lpOut.to("note"+(16*rowId)).c;
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

    inRouter
      => MBUtil.onlyHigh().from(recv("index")).c
      => mk(Processor, Eq.make(outInd)).c
      => mk(TrigValue, outInd).c
      => LP.green2().c
      => lpOut.to("note"+ind).c;
  }
}



fun void makeOutsUIRow(int rowId){
  for(0=>int outputId;outputId<OUT_DEVICE_COUNT;++outputId){
    launchpad
      => frm("note"+(rowId*16+4+outputId)).c
      => outs[rowId].to("toggleOut"+outputId).c;

    outs[rowId]
      => frm("outActive"+outputId).c
      => LP.green2().c
      => lpOut.to("note"+(rowId*16+4+outputId)).c;
  }
}



// UI SETUP

inRouter.doHandle("index", IntRef.make(0));


// Send launchpad reset message
MidiMsg msg;
176 => msg.data1;
launchpadDeviceOut.send(msg);
Util.runForever();







/* nanoktrl => mk(Printer, "nanoktrl note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c; */
/* launchpad => mk(Printer, "lp note").from("note").c; */
/* launchpad => mk(Printer, "lp cc").from("cc").c; */
/* oxygen => mk(Printer, "oxygen cc").from("cc").c; */
/* oxygen => mk(Printer, "oxygen note").from("note").c; */


/* 
 fun void setupActiveBufsIndicators(){
   for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
     for(0=>int bufId;bufId<SEQ_COUNT;++bufId){
       bufs[rowInd]
         => mk(TrigValue, rowInd*16+bufId).from("active_"+bufId).c
         => mk(NoteOut, launchpadDeviceOut, 0).c;
     }
   }
 }
 */

/* 
 metronome
   => mk(TrigValue, 7*16).c
   => mk(NoteOut, launchpadDeviceOut, 0, false).c
 ;
 */


/* 
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
 */
