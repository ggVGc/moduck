

include(song_macros.m4)
include(time_macros.m4)
include(_all_instruments.m4)
include(funcs.m4)
include(parts/rec_buf_ui.ck)
include(parts/multi_router.ck)

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


class ThingAndBuffer{
  ModuckP connector;
  ModuckP bufUI;
  ModuckP thing;
  ModuckP buf;
  def(activity, mk(Repeater));

  fun static ThingAndBuffer make(ModuckP thing, string targetTag, int bufQuantization){
    return make(thing, targetTag, mk(Repeater), bufQuantization);
  }

  fun static ThingAndBuffer make(ModuckP thing, string targetTag, ModuckP insert, int bufQuantization){
    ThingAndBuffer ret;
    thing @=> ret.thing;
    mk(RecBuf, bufQuantization) @=> ret.buf;
    def(root, mk(Repeater, [P_Trigger, P_Clock]));
    def(proxy, mk(Prio));

    root => ret.buf.listen(P_Clock).c;
    ret.buf => proxy.to(0).c;
    (root => frm(P_Trigger).c)
      .b(proxy.to(1))
      .b(ret.buf.to(P_Set));

    proxy => insert.c => thing.to(targetTag).c;
    thing => frm(recv(targetTag)).c => ret.activity.c;

    mk(Wrapper, root, thing) @=> ret.connector;
    recBufUI(ret.buf) @=> ret.bufUI;
    return ret;
  }
}


["trig", "trigpitch", "pitch", "pitchOffset"] @=> string rowTags[];


class Row{
  ModuckP outs;
  ModuckP bufUI;
  ModuckP pitchLockUI;
  ModuckP pitchShiftUI;
  def(input, mk(Repeater, rowTags));
  def(playbackRate, mk(Repeater));
  def(nudgeForward, mk(Repeater));
  def(nudgeBack, mk(Repeater));
}


fun Row makeRow(ModuckP clockIn){
  Row ret;

  ThingAndBuffer.make(mk(Repeater), P_Trigger, QUANTIZATION)
    @=> ThingAndBuffer notes;
  ThingAndBuffer.make(mk(Value, null), P_Set, MBUtil.onlyHigh(), QUANTIZATION)
    @=> ThingAndBuffer pitchLock;
  ThingAndBuffer.make(mk(Offset, 0), "offset", QUANTIZATION)
    @=> ThingAndBuffer pitchShift;

  ret.input => frm("trig").c => mk(TrigValue, 0).c => notes.connector.c;
  ret.input => frm("pitch").c => pitchLock.connector.c;
  ret.input => frm("pitchOffset").c => pitchShift.connector.c;

  ret.input => frm("trigpitch").c => mk(TrigValue, 0).c => notes.connector.c;
  ret.input => frm("trigpitch").c
    => iff(pitchLock.buf, P_Playing) // This could all be avoided with a better RecBuf implementation
      .then(iff(pitchLock.buf, "hasData")
            .then( iff(pitchLock.buf, P_Recording)
              .then(pitchLock.connector)
              .els(mk(Blackhole))
            )
            .els(pitchLock.connector)
        )
      .els(pitchLock.connector).c;

  makeTogglingOuts(OUT_DEVICE_COUNT) @=> ret.outs;

  notes.connector => MBUtil.onlyLow().c => ret.outs.c;
  notes.connector
    => mk(Delay, samp).c // Basically a hack, but needed until I have a better RecBuf implementation
    => MBUtil.onlyHigh().c
    => pitchLock.thing.c
    => iff(pitchShift.activity)
        .then(pitchShift.thing)
        .els(mk(Repeater)).c
    => ret.outs.c;

  notes.bufUI @=> ret.bufUI;
  pitchLock.bufUI @=> ret.pitchLockUI;
  pitchShift.bufUI @=> ret.pitchShiftUI;


  def(backNudgeVal, mk(TrigValue, 90));
  def(forwardNudgeVal, mk(TrigValue, 110));
  def(scalingProxy, mk(Prio));

  ret.playbackRate
    .b(scalingProxy.to(0))
    .b(mk(Add, 15) => forwardNudgeVal.to(P_Set).c)
    .b(mk(Add, -15) => backNudgeVal.to(P_Set).c) ;

  ret.nudgeForward
    => forwardNudgeVal.c
    => scalingProxy.to(1).c;

  ret.nudgeBack
    => backNudgeVal.c
    => scalingProxy.to(1).c;

  def(bufClock, mk(PulseDiv, 2));

  scalingProxy => bufClock.to("scaling").c;

  clockIn
    => mk(PulseGen, 2, Runner.timePerTick()/2).c
    => bufClock.c;

  bufClock
    .b(notes.connector.to(P_Clock))
    .b(pitchLock.connector.to(P_Clock))
    .b(pitchShift.connector.to(P_Clock));

  return ret;
}

class RowCollection{
  Row rows[0];
  def(rowIndexSelector, mk(Repeater));
  def(keysIn, mk(Repeater, rowTags));
  /* def(noteHoldToggle, mk(Toggler, false)); */
}


fun RowCollection makeRowCollection(ModuckP clockIn){
  RowCollection ret;

  ModuckP rowInputs[0];
  for(0=>int i;i<ROW_COUNT;++i){
    10::ms => now; // Keep JACK happy, prevents getting killed because of buffer underrun
    makeRow(clockIn) @=> Row row;
    rowInputs << row.input;
    ret.rows << row;
  }

  ret.rowIndexSelector => multiRouter(ret.keysIn, rowTags, rowInputs).c;

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


openOut(MIDI_OUT_MICROBRUTE) @=> MidiOut brute;
openOut(MIDI_OUT_MS_20) @=>  MidiOut ms20;
openOut(MIDI_OUT_USB_MIDI) @=> MidiOut nocoast;
openOut(MIDI_OUT_SYS1) @=> MidiOut sys1;
openOut(MIDI_OUT_CIRCUIT) @=> MidiOut circuit;


// MAPPINGS

/* 
 launchpad => frm("note"+(16*7+8)).to(rowCol.noteHoldToggle, P_Toggle).c;
 rowCol.noteHoldToggle => LP.orange().c =>lpOut.to("note"+(16*7+8)).c;
 */

setupOutputSelection();

rowCol.rows.size() => int rowCount;
launchpadKeyboard(launchpad, rowCount, rowCount+1, Scales.MinorNatural.size()) => mk(Offset, 2*7).c => rowCol.keysIn.to("trigpitch").c;
launchpadKeyboard(launchpad, rowCount+1, rowCount+2, Scales.MinorNatural.size()) => mk(Offset, 3*7).c => rowCol.keysIn.to("pitch").c;
launchpadKeyboard(launchpad, rowCount+2, rowCount+3, Scales.MinorNatural.size()) => rowCol.keysIn.to("pitchOffset").c;


/* 
 for(0=>int i;i<INPUT_TYPES;++i){
   launchpad => frm("cc"+(111-i)).to(mk(Value, i) => rowCol.inpTypeSetter.c).c;
 
   rowCol.inpTypeSetter
     => mk(Processor, Eq.make(i)).c
     => LP.orange().c
     => lpOut.to("cc"+(111-i)).c;
 }
 */



// Use one button to start/stop both trig and pitch buffer
def(trigAndPitchBufRouter, mk(Router, 0));
launchpad
  => frm("cc104").c
  => trigAndPitchBufRouter.c;
// Match index of row
rowCol.rowIndexSelector => trigAndPitchBufRouter.to("index").c;


for(0=>int rowId;rowId<rowCol.rows.size();++rowId){
  rowCol.rows[rowId] @=> Row row;
  setupRowOutputs(row);
  setupSpeedControls(row, rowId);
  makeOutsUIRow(rowId);
  setuBufferUIs(trigAndPitchBufRouter, rowId);
}


function void setuBufferUIs(ModuckP trigPitchTriggerRouter, int rowId){
  def(bufUI, rowCol.rows[rowId].bufUI);
  launchpad
    .b(frm("cc105").to(mk(Bigger, 0) => bufUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16)).to(bufUI, P_Trigger));

  bufUI => lpOut.to("note"+(16*rowId)).c;


  def(pitchLockUI, rowCol.rows[rowId].pitchLockUI);
  launchpad
    .b(frm("cc105").to(mk(Bigger, 0) => pitchLockUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+1)).to(pitchLockUI, P_Trigger));

  pitchLockUI => lpOut.to("note"+(16*rowId+1)).c;


  def(pitchShiftUI, rowCol.rows[rowId].pitchShiftUI);
  launchpad
    .b(frm("cc105").to(mk(Bigger, 0) => pitchShiftUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+2)).to(pitchShiftUI, P_Trigger));

  pitchShiftUI => lpOut.to("note"+(16*rowId+2)).c;


  (trigPitchTriggerRouter => frm(rowId).c)
    .b(bufUI)
    .b(pitchLockUI);

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
/* rowCol.inpTypeSetter.set(0); */

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

