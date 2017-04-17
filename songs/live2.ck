

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




class Row{
  ModuckP outs;
  ModuckP bufUI;
  ModuckP offsetBufUI;
  def(notesIn, mk(Repeater));
  def(inpTypeSetter, mk(Repeater));
}


fun Row makeRow(ModuckP noteHoldToggle){
  Row ret;

  def(buf, mk(RecBuf, QUANTIZATION));
  def(notesOut, mk(Repeater));
  def(pitchLocker, mk(TrigValue, null));
  def(holdTog, mk(Toggler));
  def(inpTypeRouter, mk(Router, 0, false));
  def(octaveShifter, mk(Offset, 0));
  def(pitchLockBuf, mk(RecBuf, QUANTIZATION));

  def(bufClock, mk(Repeater));

  P(Runner.masterClock)
    .b(bufClock)
    .b(pitchLockBuf.to(P_Clock));


  bufClock => buf.to(P_Clock).c;

  noteHoldToggle => MBUtil.onlyLow().c => inpTypeRouter.c;

  ret.inpTypeSetter => inpTypeRouter.to("index").c;

  ret.notesIn => inpTypeRouter.c;


  // Receives input from keyboard and recorded buffer
  def(notesProxy, mk(Prio));
  def(pitchLockProxy, mk(Prio));

  inpTypeRouter
    .b(frm(0).to(buf, P_Set))
    .b(frm(0).to(notesProxy, 1))
    .b(frm(1).to(pitchLockBuf, P_Set))
    .b(frm(1).to(pitchLockProxy, 1))
    .b(frm(2).to(mk(Offset, -60) => mk(Mul, 12).c => octaveShifter.to("offset").c));

  buf => notesProxy.to(0).c;

  pitchLockBuf => pitchLockProxy.to(0).c;
  pitchLockProxy => pitchLocker.to(P_Set).c;

  notesProxy
    => iff(pitchLocker, recv(P_Set))
      .then(pitchLocker)
      .els(mk(Repeater)).c
    => octaveShifter.c
    => notesOut.c;


  makeTogglingOuts(OUT_DEVICE_COUNT).hook(notesOut.listen(P_Trigger)) @=> ret.outs;
  recBufUI(buf) @=> ret.bufUI;
  recBufUI(pitchLockBuf) @=> ret.offsetBufUI;

  return ret;
}

class RowCollection{
  Row rows[0];
  def(inpTypeSetter, mk(Repeater));
  def(rowIndexSelector, mk(Repeater));
  def(keysIn, mk(Repeater));
  def(noteHoldToggle, mk(Toggler, false));
}


fun RowCollection setupRows(){
  RowCollection ret;

  def(inputLaneRouter, mk(Router, 0));
  ret.rowIndexSelector => inputLaneRouter.to("index").c;

  def(inputNoteHold, mk(SampleHold, 0::samp).set("forever", true));


  ret.noteHoldToggle => MBUtil.onlyLow().c => inputLaneRouter.c;

  ret.keysIn => MBUtil.onlyHigh().c => inputNoteHold.to(P_Set).c;
  ret.keysIn
    => iff(ret.noteHoldToggle, P_Trigger)
    .then(inputNoteHold => inputLaneRouter.c)
    .els(inputLaneRouter).c;

  for(0=>int i;i<ROW_COUNT;++i){
    10::ms => now; // Keep JACK happy, prevents getting killed because of buffer underrun
    makeRow(ret.noteHoldToggle) @=> Row row;
    ret.inpTypeSetter => row.inpTypeSetter.c;
    inputLaneRouter => frm(i).to(row.notesIn).c;
    ret.rows << row;
  }
  return ret;
}


setupRows() @=> RowCollection rowCol;


def(metronome, mk(Repeater));
Runner.masterClock
  => mk(PulseDiv, B).c
  => mk(SampleHold, 100::ms).c
  => metronome.c
;





// DEVICES

<<<"Opening launchpad in">>>;
def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
<<<"Opening keyboard in">>>;
/* def(keyboard, mk(MidInp, MIDI_IN_OXYGEN, 0)); */
def(keyboard, mk(MidInp, MIDI_IN_K49, 0));

MidiOut launchpadDeviceOut;
<<<"Opening launchpad out">>>;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);
/* 
 MidiOut circuitDeviceOut;
 <<<"Opening circuit out">>>;
 circuitDeviceOut.open(MIDI_OUT_CIRCUIT);
 */

def(lpOut, mk(NoteOut, launchpadDeviceOut, 0));


/* 
 def(circuit1, mk(NoteOut, circuitDeviceOut, 0));
 def(circuit2, mk(NoteOut, circuitDeviceOut, 1));
 */

// OUTPUTS

fun MidiOut openOut(int port){
  MidiOut dev;
  dev.open(port);
  50::ms => now;
  return dev;
}

openOut(MIDI_OUT_MICROBRUTE) @=> MidiOut brute;
openOut(MIDI_OUT_MS_20) @=>  MidiOut ms20;
openOut(MIDI_OUT_USB_MIDI) @=> MidiOut nocoast;
openOut(MIDI_OUT_SYS1) @=> MidiOut sys1;
openOut(MIDI_OUT_CIRCUIT) @=> MidiOut circuit;

for(0=>int rowId;rowId<rowCol.rows.size();++rowId){
  rowCol.rows[rowId].outs
    .b(frm(0).to(mk(NoteOut, circuit, 0)))
    .b(frm(1).to(mk(NoteOut, circuit, 1)))
    /* .b(frm(0).to(mk(NoteOut, brute, 0))) */
    /* 
     .b(frm(1).to(mk(NoteOut, ms20, 0)))
     .b(frm(2).to(mk(NoteOut, nocoast, 0)))
     .b(frm(3).to(mk(NoteOut, sys1, 0)))
     */
  ;
}


// MAPPINGS

keyboard => frm("note").c => rowCol.keysIn.c;


for(0=>int i;i<INPUT_TYPES;++i){
  launchpad => frm("cc"+(111-i)).to(mk(Value, i) => rowCol.inpTypeSetter.c).c;

  rowCol.inpTypeSetter
    => mk(Processor, Eq.make(i)).c
    => LP.orange().c
    => lpOut.to("cc"+(111-i)).c;
}

launchpad => frm("note"+(16*7+8)).to(rowCol.noteHoldToggle, P_Toggle).c;
rowCol.noteHoldToggle => LP.orange().c =>lpOut.to("note"+(16*7+8)).c;


launchpad => frm("note"+(16*7+0)).c => mk(TrigValue, 60).c => rowCol.keysIn.c;
launchpad => frm("note"+(16*7+1)).c => mk(TrigValue, 61).c => rowCol.keysIn.c;
launchpad => frm("note"+(16*7+2)).c => mk(TrigValue, 63).c => rowCol.keysIn.c;
launchpad => frm("note"+(16*7+3)).c => mk(TrigValue, 65).c => rowCol.keysIn.c;
launchpad => frm("note"+(16*7+4)).c => mk(TrigValue, 67).c => rowCol.keysIn.c;
launchpad => frm("note"+(16*7+5)).c => mk(TrigValue, 68).c => rowCol.keysIn.c;
launchpad => frm("note"+(16*7+6)).c => mk(TrigValue, 70).c => rowCol.keysIn.c;
launchpad => frm("note"+(16*7+7)).c => mk(TrigValue, 72).c => rowCol.keysIn.c;


setupOutputSelection();

for(0=>int rowId;rowId<ROW_COUNT;++rowId){
  makeOutsUIRow(rowId);

  def(ui, rowCol.rows[rowId].bufUI);
  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => ui.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16)).to(ui, P_Trigger));
    /* .b(frm("note"+(rowId*16)).to((mk(Value, 0) => rowCol.inpTypeSetter.c).whenNot(ui, recv(P_ClearAll)))); */

  ui => lpOut.to("note"+(16*rowId)).c;

  def(offsetUI, rowCol.rows[rowId].offsetBufUI);
  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => offsetUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+1)).to(offsetUI, P_Trigger));
    /* .b(frm("note"+(rowId*16+1)).to((mk(Value, 1) => rowCol.inpTypeSetter.c).whenNot(offsetUI, recv(P_ClearAll)))); */

  offsetUI => lpOut.to("note"+(16*rowId+1)).c;
}


fun void setupOutputSelection(){
  for(0=>int rowInd;rowInd<rowCol.rows.size();++rowInd){
    // Select outputs with side buttons
    8+rowInd*16 => int ind;
    launchpad
      => mk(Bigger,0).from("note"+ind).c
      => mk(TrigValue,rowInd).c
      => rowCol.rowIndexSelector.c
    ;

    rowCol.rowIndexSelector
      => MBUtil.onlyHigh().c
      => mk(Processor, Eq.make(rowInd)).c
      => mk(TrigValue, rowInd).c
      => LP.red().c
      => lpOut.to("note"+ind).c;
  }
}



fun void makeOutsUIRow(int rowId){
  for(0=>int outputId;outputId<OUT_DEVICE_COUNT;++outputId){
    def(outs, rowCol.rows[rowId].outs);
    launchpad
      => frm("note"+(rowId*16+4+outputId)).c
      => outs.to("toggleOut"+outputId).c;

    outs
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
rowCol.rowIndexSelector.set(0);
rowCol.inpTypeSetter.set(0);

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
