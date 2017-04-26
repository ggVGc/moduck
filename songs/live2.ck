

include(song_macros.m4)
include(time_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)
include(parts/rec_buf_ui.ck)

/* 
 TODO:
   * Trigger correct input type based on starting buf record.
 
 */



/* define(SEQ_COUNT, 1); */
define(OUT_DEVICE_COUNT, 4);
define(ROW_COUNT, 4);
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
  def(playbackRate, mk(Repeater));
  def(nudgeForward, mk(Repeater));
  def(nudgeBack, mk(Repeater));
}


fun Row makeRow(ModuckP clockIn, ModuckP noteHoldToggle){
  Row ret;

  def(buf, mk(RecBuf, QUANTIZATION));
  def(notesOut, mk(Repeater));
  def(pitchLocker, mk(TrigValue, null));
  def(holdTog, mk(Toggler));
  def(inpTypeRouter, mk(Router, 0, false));
  def(pitchShifter, mk(Offset, 0));
  def(pitchLockBuf, mk(RecBuf, QUANTIZATION));

  def(bufClock, mk(PulseDiv, 2));

  def(backNudgeVal, mk(TrigValue, 90));
  def(forwardNudgeVal, mk(TrigValue, 110));

  def(scalingProxy, mk(Prio));

  ret.playbackRate
    .b(scalingProxy.to(0))
    .b(mk(Add, 15) => forwardNudgeVal.to(P_Set).c)
    .b(mk(Add, -15) => backNudgeVal.to(P_Set).c) ;

  bufClock => frm("scaling").c => mk(Printer, "playback rate").c;

  ret.nudgeForward
    => forwardNudgeVal.c
    => scalingProxy.to(1).c;

  ret.nudgeBack
    => backNudgeVal.c
    => scalingProxy.to(1).c;

  scalingProxy => bufClock.to("scaling").c;

  clockIn
    .b(mk(PulseGen, 2, Runner.timePerTick()/2) => bufClock.c)
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
    .b(frm(2).to( mk(Offset, -14) => pitchShifter.to("offset").c));

  buf => notesProxy.to(0).c;

  pitchLockBuf => pitchLockProxy.to(0).c;
  pitchLockProxy => pitchLocker.to(P_Set).c;

  notesProxy
    => iff(pitchLocker, recv(P_Set))
        .then(pitchLocker)
        .els(mk(Repeater)).c
    => pitchShifter.c
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


fun RowCollection makeRowCollection(ModuckP clockIn){
  RowCollection ret;

  def(inputLaneRouter, mk(Router, 0));
  ret.rowIndexSelector => inputLaneRouter.to("index").c;

  def(inputNoteHold, mk(SampleHold));


  ret.noteHoldToggle => MBUtil.onlyLow().c => inputLaneRouter.c;

  ret.keysIn => MBUtil.onlyHigh().c => inputNoteHold.to(P_Set).c;
  ret.keysIn
    => iff(ret.noteHoldToggle, P_Trigger)
    .then(inputNoteHold => inputLaneRouter.c)
    .els(inputLaneRouter).c;

  for(0=>int i;i<ROW_COUNT;++i){
    10::ms => now; // Keep JACK happy, prevents getting killed because of buffer underrun
    makeRow(clockIn, ret.noteHoldToggle) @=> Row row;
    ret.inpTypeSetter => row.inpTypeSetter.c;
    inputLaneRouter => frm(i).to(row.notesIn).c;
    ret.rows << row;
  }
  return ret;
}


def(clock, mk(Repeater));

makeRowCollection(clock) @=> RowCollection rowCol;

// DEVICES


Runner.masterClock => clock.c;

<<<"Opening launchpad in">>>;
def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
<<<"Opening keyboard in">>>;
/* def(keyboard, mk(MidInp, MIDI_IN_CIRCUIT, 0)); */
def(nanoK, mk(MidInp, MIDI_IN_NANO_KTRL, 0));
/* def(keyboard, mk(MidInp, MIDI_IN_OXYGEN, 0)); */
/* def(keyboard, mk(MidInp, MIDI_IN_K49, 0)); */
/* def(circuitIn, mk(MidInp, MIDI_IN_CIRCUIT, 9)); */


nanoK => mk(Printer, "nano").from("cc").c;

openOut(MIDI_OUT_LAUNCHPAD) @=> MidiOut launchpadDeviceOut;
def(lpOut, mk(NoteOut, launchpadDeviceOut, 0));

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


// MAPPINGS

launchpad => frm("note"+(16*7+8)).to(rowCol.noteHoldToggle, P_Toggle).c;
rowCol.noteHoldToggle => LP.orange().c =>lpOut.to("note"+(16*7+8)).c;

setupOutputSelection();
launchpadKeyboard(launchpad, rowCol.rows.size(), 8, Scales.MinorNatural.size()) => rowCol.keysIn.c;


for(0=>int i;i<INPUT_TYPES;++i){
  launchpad => frm("cc"+(111-i)).to(mk(Value, i) => rowCol.inpTypeSetter.c).c;

  rowCol.inpTypeSetter
    => mk(Processor, Eq.make(i)).c
    => LP.orange().c
    => lpOut.to("cc"+(111-i)).c;
}


for(0=>int rowId;rowId<rowCol.rows.size();++rowId){
  rowCol.rows[rowId] @=> Row row;
  setupRowOutputs(row);
  setupSpeedControls(row, rowId);
  makeOutsUIRow(rowId);
  setuBufferUIs(rowId);
}


function void setuBufferUIs(int rowId){
  def(ui, rowCol.rows[rowId].bufUI);
  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => ui.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16)).to(ui, P_Trigger));

  ui => lpOut.to("note"+(16*rowId)).c;

  def(offsetUI, rowCol.rows[rowId].offsetBufUI);
  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => offsetUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+1)).to(offsetUI, P_Trigger));

  offsetUI => lpOut.to("note"+(16*rowId+1)).c;
}


function void setupSpeedControls(Row row, int rowId){
  // Make it easier to go to center by splitting into 3 intervals
  (nanoK => frm("cc"+(14+rowId)).c)
    .b(mk(RangeMapper, 0, 55, 0, 99) => row.playbackRate.c)
    .b(mk(RangeMapper, 56, 73, 100, 100) => row.playbackRate.c)
    .b(mk(RangeMapper, 74, 127, 101, 200) => row.playbackRate.c);
  nanoK => frm("cc"+(23+rowId)).c => row.nudgeForward.c;
  nanoK => frm("cc"+(33+rowId)).c => row.nudgeBack.c;
}


function ModuckP outPitchQuant(){
    return mk(Repeater)
      => mk(Mapper, Scales.MinorNatural, 12).c
      => octaves(3).c;
}

function void setupRowOutputs(Row row){
  row.outs
    .b(frm(0).to(outPitchQuant() => mk(NoteOut,circuit,0).c))
    .b(frm(1).to(outPitchQuant() => mk(NoteOut,circuit,1).c))
    .b(frm(0).to( mk(Printer, "OUT 0")))
    .b(frm(1).to( mk(Printer, "OUT 1")))
    /* .b(frm(2).to(mk(NoteOut,circuit,9))) */
    /*.b(frm(2).to(mk(NoteOut,circuit,10)))*/
    /*.b(frm(3).to(mk(NoteOut,circuit,12)))*/
    /*.b(frm(0).to(mk(NoteOut,brute,0)))
    /* 
     .b(frm(1).to(mk(NoteOut, ms20, 0)))
     .b(frm(2).to(mk(NoteOut, nocoast, 0)))
     .b(frm(3).to(mk(NoteOut, sys1, 0)))
     */
  ;
}




function void setupOutputSelection(){
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



function void makeOutsUIRow(int rowId){
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


function ModuckP launchpadKeyboard(ModuckP launchpadInstance, int startRow, int endRow, int width){
  def(out, mk(Repeater));
  endRow-startRow => int maxInd;
  for(0=>int rowInd;rowInd<maxInd;++rowInd){
    for(0=>int i;i<width;++i){
      launchpadInstance
        => frm("note"+((startRow + (maxInd-rowInd-1))*16+i)).c
        => mk(TrigValue, (rowInd*width+i)).c
        => out.c;
    }
  }
  return out;
}



// Send launchpad reset message
MidiMsg msg;
176 => msg.data1;
launchpadDeviceOut.send(msg);

samp =>  now;
rowCol.rowIndexSelector.set(0);
rowCol.inpTypeSetter.set(0);

Util.runForever();



/* 
 def(bcr, mk(MidInp, MIDI_IN_BCR, 8));
 bcr => frm("cc40").c => mk(Printer, "bcr").c;
 */

/* 
 circuitIn => frm("cc").c => mk(Printer, "Circuit cc").c;
 circuitIn => frm("note").c => mk(Printer, "Circuit note").c;
 circuitIn => mk(Printer, "Circuit").c;
 */

/* def(clockGen, mk(PulseGen, Runner.ticksPerBeat/4, Runner.timePerTick())); */

/* def(deltCont, mk(DeltaCounter)); */

/* deltCont => mk(Printer, "delta").c; */

/* 
 (deltCont => mk(Bigger, Util.toSamples(500::ms)).c)
   .b(deltCont.to(P_Reset))
   .b(clockGen.to(P_Reset));
 */

/* 
 circuitIn
   => frm("note65").c
   => deltCont.c
   => mk(Div, Runner.ticksPerBeat/4).c
   => clockGen.to("delta").c;
 */



/* 
 circuitIn => frm("note65").c
   => clockGen.c
   => clock.c;
 */

