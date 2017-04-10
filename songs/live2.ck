

include(song_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)
include(parts/rec_buf_ui.ck)

/* 
 TODO:
   * Trigger correct input type based on starting buf record.
 
 */



/* define(SEQ_COUNT, 1); */
define(OUT_DEVICE_COUNT, 4);
define(ROW_COUNT, 7);
define(INPUT_TYPES, 3);
define(QUANTIZATION, Bar)


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
ModuckP bufUIs[0];
ModuckP offsetBufUIs[0];
def(setInpType, mk(Repeater));

def(inputLaneRouter, mk(Router, 0));

def(noteHoldToggle, mk(Toggler, false));
def(inputNoteHold, mk(SampleHold, 0::samp).set("forever", true));

keysIn => MBUtil.onlyHigh().c => inputNoteHold.to(P_Set).c;
keysIn
  => iff(noteHoldToggle, P_Trigger)
    .then(inputNoteHold => inputLaneRouter.c)
    .els(inputLaneRouter).c;


for(0=>int i;i<ROW_COUNT;++i){
  10::ms => now; // Keep JACK happy
  def(buf, mk(RecBuf, QUANTIZATION));
  def(notesOut, mk(Repeater));
  def(pitchLocker, mk(Value, null));
  def(holdTog, mk(Toggler));
  def(inpTypeRouter, mk(Router, 0, false));
  def(pitchShifter, mk(Offset, 0));
  def(pitchLockBuf, mk(RecBuf, QUANTIZATION));
  def(notesProxy, mk(Repeater));

  P(Runner.masterClock)
    .b(buf.to(P_Clock))
    .b(pitchLockBuf.to(P_Clock));

  noteHoldToggle => MBUtil.onlyLow().c => inpTypeRouter.c;
  noteHoldToggle => MBUtil.onlyLow().c => inputLaneRouter.c;

  setInpType => inpTypeRouter.to("index").c;

  inputLaneRouter => frm(i).to(inpTypeRouter).c;

  pitchLockBuf => pitchLocker.to(P_Set).c;
  /* 
   pitchLockBuf
     => frm(recv(toggl(P_Rec))).c
     => MBUtil.onlyHigh().c
     => mk(Value, 1).c => inpTypeRouter.c;

   buf
     => frm(recv(toggl(P_Rec))).c
     => MBUtil.onlyHigh().c
     => mk(Value, 0).c => inpTypeRouter.c;
   */
  inpTypeRouter
    .b(frm(0).to(buf, P_Set))
    .b(frm(0).to(MBUtil.onlyHigh() => notesProxy.c))
    .b(frm(0).to(MBUtil.onlyLow() => notesProxy.whenNot(buf, P_Trigger).c))
    .b(frm(1).to(pitchLocker, P_Set))
    .b(frm(1).to(pitchLockBuf, P_Set))
    .b(frm(2).to(mk(Offset, -60) => pitchShifter.to("offset").c));

  buf => notesProxy.c;

  notesProxy
    => iff(pitchLocker, recv(P_Set))
      .then(pitchLocker)
      .els(mk(Repeater)).c
    => pitchShifter.c
    => notesOut.c;

  notesProxy
    => MBUtil.onlyLow().c
    => notesOut.c;

  def(out, makeTogglingOuts(OUT_DEVICE_COUNT).hook(notesOut.listen(P_Trigger)));

  bufUIs << recBufUI(buf);
  offsetBufUIs << recBufUI(pitchLockBuf);
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


for(0=>int i;i<INPUT_TYPES;++i){
  launchpad => frm("cc"+(111-i)).to(mk(Value, i) => setInpType.c).c;

  setInpType
    => mk(Processor, Eq.make(i)).c
    => LP.orange().c
    => lpOut.to("cc"+(111-i)).c;
}

launchpad => frm("note"+(16*7)).to(noteHoldToggle, P_Toggle).c;
noteHoldToggle => LP.orange().c =>lpOut.to("note"+(16*7)).c;


setupOutputSelection();

for(0=>int rowId;rowId<ROW_COUNT;++rowId){
  makeOutsUIRow(rowId);

  def(ui, bufUIs[rowId]);
  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => ui.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16)).to(ui, P_Trigger))
    .b(frm("note"+(rowId*16)).to(mk(Value, 0) => setInpType.c));

  ui => lpOut.to("note"+(16*rowId)).c;

  def(offsetUI, offsetBufUIs[rowId]);
  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => offsetUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+1)).to(offsetUI, P_Trigger))
    .b(frm("note"+(rowId*16+1)).to(mk(Value, 1) => setInpType.c));

  offsetUI => lpOut.to("note"+(16*rowId+1)).c;
}


fun void setupOutputSelection(){
  for(0=>int outInd;outInd<outs.size();++outInd){
    // Select outputs with side buttons
    8+outInd*16 => int ind;
    launchpad
      => mk(Bigger,0).from("note"+ind).c
      => mk(TrigValue,outInd).c
      => inputLaneRouter.to("index").c
    ;

    inputLaneRouter
      => MBUtil.onlyHigh().from(recv("index")).c
      => mk(Processor, Eq.make(outInd)).c
      => mk(TrigValue, outInd).c
      => LP.red().c
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
      => LP.red().c
      => lpOut.to("note"+(rowId*16+4+outputId)).c;
  }
}



// UI SETUP



// Send launchpad reset message
MidiMsg msg;
176 => msg.data1;
launchpadDeviceOut.send(msg);

samp =>  now;
inputLaneRouter.set("index", 0);
setInpType.set(0);

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
