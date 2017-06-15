include(song_macros.m4)
include(time_macros.m4)
include(funcs.m4)
include(parts/rec_buf_ui.ck)
include(parts/multi_router.ck)
include(parts/multi_switcher.ck)
include(parts/rhythms.ck)
include(parts/toggling_outs.ck)

define(OUT_DEVICE_COUNT, 3);
define(ROW_COUNT, 8)
define(QUANTIZATION, Bar)

Runner.setPlaying(1);


fun ModuckP makeBeatRitmo(){
  Runner.getBpm()*2 => int b;
  [
    mk(ClockGen, b/3)
    ,mk(ClockGen, (b*2)/3)
    ,mk(ClockGen, b/2+b/4)
    ,mk(ClockGen, b+b/2)
    ,mk(ClockGen, b/2)
    ,mk(ClockGen, b)
    ,mk(ClockGen, b*2)
    ,mk(ClockGen, b*4)
    ,mk(ClockGen, b*8)
  ] @=> ModuckP parts[];

  Util.genStringNums(parts.size()-1) @=> string tags[];

  def(root, mk(Repeater, tags));
  def(out, mk(Repeater));


  for(0=>int ind;ind<parts.size();++ind){
    parts[ind] @=> ModuckP part;
      root => frm(ind).c
        => part.to(P_Gate).c
        => out.c;
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

  fun static ModuckP routeTag(string bufToTag, ModuckP root, ModuckP buf){
    def(proxy, mk(Prio));
    buf => proxy.to(0).c;
    root
      .b(proxy.to(1))
      .b(buf.to(bufToTag));

    return proxy;
  }


  fun static ThingAndBuffer make(ModuckP thing, string targetTag, ModuckP insert, int bufQuantization){
    ThingAndBuffer ret;
    thing @=> ret.thing;
    mk(RecBuf, bufQuantization) @=> ret.buf;
    def(root, mk(Repeater,
          Util.concatStrings([
            [P_Trigger, P_Clock]
      ])));

    root => ret.buf.listen(P_Clock).c;

    if(targetTag != null){
      routeTag(P_Set, root => frm(P_Trigger).c, ret.buf)
        => insert.c
        => thing.to(targetTag).c;
      thing => frm(recv(targetTag)).c => ret.activity.c;
    }

    mk(Wrapper, root, thing) @=> ret.connector;
    recBufUI(ret.buf) @=> ret.bufUI;

    // Kill input when playback starts
    MUtil.sigEq(ret.buf, "state", RecBuf.Playing)
      => mk(TrigValue, null).c
      => mk(SampleHold, samp).c
      => MBUtil.onlyLow().c
      => ret.connector.c;

    return ret;
  }
}


Util.concatStrings([
    ["trig", "trigpitch", "pitch", "pitchOffset", "noteLengthMultiplier", "noteTimeMul"]
]) @=> string rowTags[];


class Row{
  ModuckP outs;
  ModuckP bufUI;
  ModuckP pitchLockUI;
  ModuckP pitchShiftUI;
  def(pitchShiftOut, mk(Value, 0).set("triggerOnSet", true));
  /* ModuckP beatRitmoUI; */
  def(input, mk(Repeater, rowTags));
}


fun Row makeRow(ModuckP clockIn){
  Row ret;

  ThingAndBuffer.make(mk(Repeater), P_Trigger, QUANTIZATION)
    @=> ThingAndBuffer notes;
  ThingAndBuffer.make(mk(Value, null), P_Set, MBUtil.onlyHigh(), QUANTIZATION)
    @=> ThingAndBuffer pitchLock;
  ThingAndBuffer.make(mk(Offset, 0), "offset", QUANTIZATION)
    @=> ThingAndBuffer pitchShift;


  ret.input => frm("trigpitch").c => pitchLock.connector.c;
  ret.input => frm("pitch").c => pitchLock.connector.c;
  ret.input => frm("trig").c => mk(TrigValue, 0).c => notes.connector.c;
  ret.input => frm("pitchOffset").c => pitchShift.connector.c;
  ret.input => frm("trigpitch").c => mk(TrigValue, 0).c => notes.connector.c;
  (ret.input => frm("noteLengthMultiplier").c)
    .b(notes.buf.to("lengthMultiplier"))
    .b(pitchLock.buf.to("lengthMultiplier"))
    .b(pitchShift.buf.to("lengthMultiplier"));
  (ret.input => frm("noteTimeMul").c)
    .b(notes.buf.to("timeMul"))
    .b(pitchLock.buf.to("timeMul"))
    .b(pitchShift.buf.to("timeMul"));

  pitchShift.thing
    => frm(recv("offset")).c
    => MBUtil.onlyHigh().c
    => ret.pitchShiftOut.to(P_Set).c;
  ret.pitchShiftOut => mk(Printer, "Pitch shift").c;

  togglingOuts(OUT_DEVICE_COUNT) @=> ret.outs;

  notes.connector => MBUtil.onlyLow().c => ret.outs.c;
  notes.connector
    => MBUtil.onlyHigh().c
    => pitchLock.thing.c
    => iff(pitchShift.activity)
        .then(pitchShift.thing)
        .els(mk(Repeater)).c
    => ret.outs.c;

  notes.bufUI @=> ret.bufUI;
  pitchLock.bufUI @=> ret.pitchLockUI;
  pitchShift.bufUI @=> ret.pitchShiftUI;

  clockIn
    .b(notes.connector.to(P_Clock))
    .b(pitchLock.connector.to(P_Clock))
    .b(pitchShift.connector.to(P_Clock));

  return ret;
}


class RowCollection{
  Row rows[0];
  def(rowIndexSelector, mk(Value, 0).set("triggerOnSet", true));
  def(keysIn, mk(Repeater, rowTags));
}


fun RowCollection makeRowCollection(ModuckP clockIn){
  RowCollection ret;

  ModuckP rowInputs[0];
  for(0=>int i;i<ROW_COUNT;++i){
    10::ms => now;
    makeRow(clockIn) @=> Row row;
    rowInputs << row.input;
    ret.rows << row;
  }

  ret.rowIndexSelector => multiRouter(ret.keysIn, rowTags, rowInputs, false).c;

  return ret;
}


def(clock, mk(Repeater));
makeRowCollection(clock) @=> RowCollection rowCol;


// DEVICES


Runner.masterClock => clock.c;

openOut(MIDI_OUT_LAUNCHPAD) @=> MidiOut launchpadDeviceOut;
def(launchpad, mk(Wrapper, 
    mk(NoteOut, launchpadDeviceOut, 0)
    ,mk(MidInp, MIDI_IN_LAUNCHPAD, 0)
));


def(apc, mk(Wrapper, 
    apcToLaunchadAdapterOut(mk(NoteOut, openOut(MIDI_OUT_APC), 0, true))
    ,apcToLaunchadAdapterIn(mk(MidInp, MIDI_IN_APC, 0))
));

def(maschine, mk(Wrapper, 
    mk(NoteOut, openOut(MIDI_OUT_IAC_1), 0, true)
    ,mk(MidInp, MIDI_IN_IAC_1, 0)
));

def(keyboard, mk(MidInp, MIDI_IN_K49, 0));

openOut(MIDI_OUT_CIRCUIT) @=> MidiOut circuitDeviceOut;

def(circuitKeyboard, mk(Wrapper, 
    mk(NoteOut, circuitDeviceOut, 1)
    ,mk(MidInp, MIDI_IN_CIRCUIT, 1)
));

def(beatRitmo, makeBeatRitmo());

def(beatRitmoHolder, mk(SampleHold, D16));
def(beatRitmoTimeSrc, mk(Repeater));

beatRitmoTimeSrc
  => mk(RangeMapper, 0, 127, 1, Util.toSamples(D)).c
  => beatRitmoHolder.to("holdTime").c;

beatRitmo 
  => beatRitmoHolder.to(P_Set).to(P_Trigger).c
  => rowCol.keysIn.to("trig").c;


// MAPPINGS


fun ModuckP absoluteToRelative(ModuckP m){
  def(out, mk(Repeater));

  m
  .b(mk(Bigger, 63) => mk(Value, 1).c => out.c)
  .b(mk(Smaller, 63) => mk(Value, -1).c => out.c)
  .b(mk(Value, 63) => m.c);

  return out;
}


fun ModuckP twoWay(ModuckP m, string tag){
  return mk(Wrapper, mk(Repeater) => m.to(tag).c, m => frm(tag).c);
}


fun ModuckP relativeValue(int min, int max){
  def(root, mk(Repeater, [P_Trigger, P_Set, "inc", "dec"]));
  def(val, mk(Value, min));

  root => val.listen([P_Trigger, P_Set]).c;

  root => frm("inc").c
    => mk(Value, min).hook(val.from(recv(P_Set)).to(P_Set)).c
    => mk(Add, 1).c => val.to(P_Set).c;

  root => frm("dec").c 
    => mk(Value, min).hook(val.from(recv(P_Set)).to(P_Set)).c
    => mk(Add, -1).c => val.to(P_Set).c;

  (val => frm(recv(P_Set)).c)
    .b(mk(Smaller, min) => mk(Value, min).c => val.to(P_Set).c)
    .b(mk(Bigger, max) => mk(Value, max).c => val.to(P_Set).c);

  return mk(Wrapper, root, val);
}


circuitKeyboard => frm("cc80").c => beatRitmoTimeSrc.c;

rowMultiControl("noteLengthMultiplier", twoWay(circuitKeyboard, "cc81"), 1, 1000, 100);
rowMultiControl("noteTimeMul", twoWay(circuitKeyboard, "cc82"), 1, 1000, 100);

// Reset controller values
(apc => frm("cc106").c)
  .b(mk(TrigValue, 100) => rowCol.keysIn.to("noteLengthMultiplier").c)
  .b(mk(TrigValue, 100) => rowCol.keysIn.to("noteTimeMul").c);


fun void rowMultiControl(string rowInputTag, ModuckP m, int minVal, int maxVal, int startVal){
  def(absRelInput, absoluteToRelative(m));
  def(relVal, relativeValue(minVal, maxVal));
  absRelInput => mk(Bigger, 0).c => relVal.to("inc").c;
  absRelInput => mk(Smaller, 0).c => relVal.to("dec").c;

  absRelInput
    => mk(Delay, samp).c
    => relVal.c;

  relVal => rowCol.keysIn.to(rowInputTag).c;

  ModuckP sources[0];
  for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
    sources <<
      (rowCol.rows[rowInd].input
      => frm(recv(rowInputTag)).c
      => MBUtil.onlyHigh().c
    );
  }

  rowCol.rowIndexSelector => multiSwitcher(false, sources, [P_Trigger], 
    mk(Repeater)
    => relVal.to(P_Set).c
  ).c;

  for(0=>int i;i<ROW_COUNT;++i){
    rowCol.rows[i].input.doHandle(rowInputTag, startVal);
  }
}


setupOutputSelection();
setupBeatRitmoUI(clock, launchpad, beatRitmo);

// Use one button to start/stop both trig and pitch buffer
def(trigAndPitchBufRouter, mk(Router, 0));
apc
  => frm("cc104").c
  => trigAndPitchBufRouter.c;
// Match index of row
rowCol.rowIndexSelector => trigAndPitchBufRouter.to("index").c;


apc
  => frm("cc104").c
  => mk(Value, 50).c
  => circuitKeyboard.to("cc81").c;


for(0=>int rowId;rowId<rowCol.rows.size();++rowId){
  10::ms => now;
  rowCol.rows[rowId] @=> Row row;
  setupRowOutputs(row);
  /* setupSpeedControls(row, rowId); */ // TODO: Enable speed controls again
  makeOutsUIRow(rowId);
  setupBufferUIs(trigAndPitchBufRouter, rowId);
}


keyboard
  => frm("note").c
  => mk(Printer, "kb note").c
  => mk(Mapper, Scales.fromChromatic(Scales.MinorNatural), Scales.MinorNatural.size()).c
  => mk(Printer, "kb ").c
  => rowCol.keysIn.to("trigpitch").c;
circuitKeyboard => frm("note").c
  => mk(Offset, -4*12).c
  => rowCol.keysIn.to("trigpitch").c;

def(trigPitchToggle, mk(Toggler, false));

trigPitchToggle => LP.green().c => launchpad.to("cc104").c;
launchpad => frm("cc104").c => mk(Bigger, 0).c => trigPitchToggle.to(P_Toggle).c;


Scales.MinorNatural.size() => int scaleNoteCount;
launchpadKeyboard(launchpad, 0, 5, scaleNoteCount) @=> ModuckP triggerKeyboard;
triggerKeyboard
  => mk(Offset, 2*Scales.MinorNatural.size()).c
  => iff(trigPitchToggle, P_Trigger)
    .then(rowCol.keysIn.to("pitch"))
    .els(rowCol.keysIn.to("trigpitch")).c;


ModuckP rowOutputs[0];
for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
  rowOutputs <<
    (rowCol.rows[rowInd].outs
    => frm(recv(P_Trigger)).c
    => mk(Offset, -2*Scales.MinorNatural.size()).c
    => mk(NumToOut, Util.range(7*5)).c);
}

rowCol.rowIndexSelector => multiSwitcher(rowOutputs, Util.genStringNums(7*5), triggerKeyboard).c;


launchpadKeyboard(launchpad, 5, 8, scaleNoteCount) @=> ModuckP pitchOffsetKb;
pitchOffsetKb => mk(Offset, -7).c => rowCol.keysIn.to("pitchOffset").c;

ModuckP rowPitchOffsets[0];
for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
  rowPitchOffsets <<
    (rowCol.rows[rowInd].pitchShiftOut
    => mk(Offset, 7).c
    => mk(NumToOut, Util.range(7*3)).c
    );
}

rowCol.rowIndexSelector => multiSwitcher(rowPitchOffsets, Util.genStringNums(7*3), pitchOffsetKb).c;
for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
  rowCol.rows[rowInd].pitchShiftOut.set(P_Trigger, true);
}


fun void setupBeatRitmoUI(ModuckP clockIn, ModuckP controllerSrc, ModuckP ritmo){
  for(0=>int i;i<8;++i){
    def(onceTrig, mk(OnceTrigger));
    clockIn => onceTrig.to(P_Trigger).c;
    (controllerSrc => frm("note"+(7+(7-i)*16)).c)
      .b(
          mk(Repeater)
          => onceTrig.to(P_Set).c
          => ritmo.to(i).c
        )
      .b( MBUtil.onlyLow() => ritmo.to(i).c);
  }
}


fun ModuckP apcToLaunchadAdapterOut(ModuckP apcInstance){
  8 => int width;
  8 => int height;

  Util.numberedStrings("note", Util.range(0,64)) @=> string noteTags1[];
  10::ms => now;
  Util.numberedStrings("note", Util.range(65,127)) @=> string noteTags2[];
  10::ms  => now;
  Util.numberedStrings("cc", Util.range(0,64)) @=> string ccTags1[];
  10::ms => now;
  Util.numberedStrings("cc", Util.range(65,127)) @=> string ccTags2[];
  10::ms  => now;
  
  def(rep, mk(Repeater, Util.concatStrings([
        Util.concatStrings([noteTags1, noteTags2])
        ,Util.concatStrings([ccTags1, ccTags2])
        ,["note", "cc"]
  ])));

  for(0=>int y;y<height;++y){
    for(0=>int x;x<width;++x){
      10::ms => now;
      rep
        => frm("note"+(x+(height-1-y)*16)).c
        => apcInstance.to("note"+(x+(width*y))).c;
    }
  }

  for(64=>int i;i<64+width;++i){
    10::ms => now;
    rep
      => frm("cc"+((i-64)+104)).c
      => apcInstance.to("note"+i).c;
  }

  for(82=>int i;i<82+height;++i){
    10::ms => now;
    rep
      => apcInstance.fromTo("note"+((i-82)*16 + 8), "note"+i).c;
  }
  
  rep => frm("note").c
    => mk(Printer, "Warning - Not implemented: FILIN").c
    => apcInstance.to("note").c; // TODO: Need to actually transform this value
  rep => frm("cc").c
    => mk(Printer, "Warning - Not implemented: FILIN").c
    => apcInstance.to("cc").c; // TODO: Need to actually transform this value



  return rep;
}


fun ModuckP apcToLaunchadAdapterIn(ModuckP apcInstance){
  8 => int width;
  8 => int height;

  Util.numberedStrings("note", Util.range(0,64)) @=> string noteTags1[];
  10::ms => now;
  Util.numberedStrings("note", Util.range(65,127)) @=> string noteTags2[];
  10::ms  => now;
  Util.numberedStrings("cc", Util.range(0,64)) @=> string ccTags1[];
  10::ms => now;
  Util.numberedStrings("cc", Util.range(65,127)) @=> string ccTags2[];
  10::ms  => now;


  
  def(rep, mk(Repeater, Util.concatStrings([
        Util.concatStrings([noteTags1, noteTags2])
        ,Util.concatStrings([ccTags1, ccTags2])
        ,["note", "cc"]
  ])));

  for(0=>int y;y<height;++y){
    for(0=>int x;x<width;++x){
      10::ms => now;
      apcInstance
        => frm("note"+(x+(width*y))).c
        => rep.to("note"+(x+(height-1-y)*16)).c;
    }
  }

  for(64=>int i;i<64+width;++i){
    10::ms => now;
    apcInstance
      => frm("note"+i).c
      => rep.to("cc"+((i-64)+104)).c;
  }

  for(82=>int i;i<82+height;++i){
    10::ms => now;
    apcInstance
      => rep.fromTo("note"+i, "note"+((i-82)*16 + 8)).c;
  }


  apcInstance => frm("note").c => rep.to("note").c;
  apcInstance => frm("cc").c => rep.to("cc").c;

  return rep;
}


function void setupBufferUIs(ModuckP trigPitchTriggerRouter, int rowId){
  def(bufUI, rowCol.rows[rowId].bufUI);
  apc
    .b(frm("cc105").to(mk(Bigger, 0) => bufUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16)).to(bufUI, P_Trigger));

  bufUI => apc.to("note"+(16*rowId)).c;


  def(pitchLockUI, rowCol.rows[rowId].pitchLockUI);
  apc
    .b(frm("cc105").to(mk(Bigger, 0) => pitchLockUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+1)).to(pitchLockUI, P_Trigger));

  pitchLockUI => apc.to("note"+(16*rowId+1)).c;


  def(pitchShiftUI, rowCol.rows[rowId].pitchShiftUI);
  apc
    .b(frm("cc105").to(mk(Bigger, 0) => pitchShiftUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+2)).to(pitchShiftUI, P_Trigger));

  pitchShiftUI => apc.to("note"+(16*rowId+2)).c;

  (trigPitchTriggerRouter => frm(rowId).c)
    .b(bufUI)
    .b(pitchLockUI);
}


/* 
 function void setupSpeedControls(Row row, int rowId){
   // Make it easier to go to center by splitting into 3 intervals
   (nanoK => frm("cc"+(14+rowId)).c)
     .b(mk(RangeMapper, 0, 55, 0, 99) => row.playbackRate.c)
     .b(mk(RangeMapper, 56, 73, 100, 100) => row.playbackRate.c)
     .b(mk(RangeMapper, 74, 127, 101, 200) => row.playbackRate.c);
   nanoK => frm("cc"+(23+rowId)).c => row.nudgeForward.c;
   nanoK => frm("cc"+(33+rowId)).c => row.nudgeBack.c;
 }
 */


function ModuckP outPitchQuant(){
    return mk(Repeater) => mk(Mapper, Scales.MinorNatural, 12).c;
}


function void setupRowOutputs(Row row){
  row.outs
    .b(frm(0).to(outPitchQuant() => mk(NoteOut,circuitDeviceOut,0).c))
    .b(frm(1).to(outPitchQuant() => mk(NoteOut,circuitDeviceOut,1).c))
    .b(frm(2).to(mk(Offset, 7*4-3) => mk(NoteOut,circuitDeviceOut,9).c)) // Drums
  ;
}

function void setupOutputSelection(){
  for(0=>int rowInd;rowInd<rowCol.rows.size();++rowInd){
    // Select outputs with side buttons
    8+rowInd*16 => int ind;
    apc
      => mk(Bigger,0).from("note"+ind).c
      => mk(TrigValue,rowInd).c
      => rowCol.rowIndexSelector.to(P_Set).c
    ;

    rowCol.rowIndexSelector
      => MBUtil.onlyHigh().c
      => mk(Processor, Eq.make(rowInd)).c
      => mk(TrigValue, rowInd).c
      => LP.red().c
      => apc.to("note"+ind).c;
  }
}


function void makeOutsUIRow(int rowId){
  for(0=>int outputId;outputId<OUT_DEVICE_COUNT;++outputId){
    def(outs, rowCol.rows[rowId].outs);
    5 + rowId*16+outputId => int ind;
    apc
      => frm("note"+ind).c
      => outs.to("toggleOut"+outputId).c;

    outs
      => frm("outActive"+outputId).c
      => LP.red().c
      => apc.to("note"+ind).c;
  }
}


function ModuckP launchpadKeyboard(ModuckP launchpadInstance, int startRow, int endRow, int width){
  endRow-startRow => int maxInd;
  def(in, mk(Repeater, Util.numberedStrings("", Util.range(0,width*(endRow-startRow)))));

  def(out, mk(Repeater, Util.concatStrings([
    ["note"]
    ,Util.numberedStrings("", Util.range(0,width*(endRow-startRow)))
  ])));

  for(0=>int rowInd;rowInd<maxInd;++rowInd){
    for(0=>int i;i<width;++i){
      rowInd*width+i => int ind;
      (launchpadInstance => frm("note"+((startRow + (maxInd-rowInd-1))*16+i)).c => mk(TrigValue, ind).c)
        .b(out.to("note"))
        .b(out.to(ind));
      10::ms => now;
      in
        => frm(ind).c
        /* => mk(Printer, "from "+ind).c */
        => LP.red().c
        => launchpadInstance.to("note"+((startRow + (maxInd-rowInd-1))*16+i)).c;
    }
  }

  return mk(Wrapper, in, out);
}



// Send launchpad reset message
MidiMsg msg;
176 => msg.data1;
launchpadDeviceOut.send(msg);

samp =>  now;
rowCol.rowIndexSelector.set(P_Set, 0);

Util.runForever();



// Clock experiment

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

