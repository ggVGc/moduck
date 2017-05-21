

include(song_macros.m4)
include(time_macros.m4)
include(funcs.m4)
include(parts/rec_buf_ui.ck)
include(parts/multi_router.ck)
include(parts/multi_switcher.ck)
include(parts/rhythms.ck)
include(parts/toggling_outs.ck)
// # include(instruments/ritmo2.ck)

define(OUT_DEVICE_COUNT, 6);
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
    /* string tags[0]; */
    /* return make(thing, targetTag, mk(Repeater), bufQuantization, tags); */
    return make(thing, targetTag, mk(Repeater), bufQuantization);
  }


  /* 
   fun static ThingAndBuffer make(ModuckP thing, string targetTag, ModuckP insert, int bufQuantization){
     string tags[0];
     return make(thing, targetTag, insert, bufQuantization, tags);
   }
   */

  fun static ModuckP routeTag(string bufToTag, ModuckP root, ModuckP buf){
    def(proxy, mk(Prio));
    buf => proxy.to(0).c;
    root
      .b(proxy.to(1))
      .b(buf.to(bufToTag));

    return proxy;
  }


  /* fun static ThingAndBuffer make(ModuckP thing, string targetTag, ModuckP insert, int bufQuantization, string recTags[]){ */
  fun static ThingAndBuffer make(ModuckP thing, string targetTag, ModuckP insert, int bufQuantization){
    ThingAndBuffer ret;
    thing @=> ret.thing;
    /* mk(RecBuf, bufQuantization, recTags) @=> ret.buf; */
    mk(RecBuf, bufQuantization) @=> ret.buf;
    def(root, mk(Repeater,
          Util.concatStrings([
            [P_Trigger, P_Clock]
            /* ,recTags */
      ])));

    root => ret.buf.listen(P_Clock).c;


    /* 
     for(0=>int tag;tag<recTags.size();++tag){
       recTags[tag] @=> string tag;
       routeTag(tag, root => frm(tag).c , ret.buf)
         // => insert.c  // HACK: insert moduck isn't well defined, and has only one use case so far. And it's not used together with multiple rec tags
                           // If needed, there needs to be one copy of the 'insert' for each tag. Alternatively an output router,
                           // and set the index before sending the signal before routing through the 'insert' to the output.
         => thing.to(tag).c;
     }
     */



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


[
    /* fourFour(B*2) */
    fourFour(B+B2)
    ,fourFour(B2+B4)
    ,fourFour(B/3)
    ,fourFour(B)
    ,fourFour(B2)
    ,fourFour(B4)
    ,fourFour(B8)
    ,fourFour(B16)
    /* ,fourFour(B32) */
    /* ,mk(Blackhole) */

    /* ,fourFour(B4+B8) */
    /* ,fourFour(B16+B32) */
    /* ,fourFour(B7, 0) */
    /* ,fourFour(B5, 0) */
    /* ,fourFour(B3, 0) */
] @=> ModuckP beatRitmoParts[];


/* Util.genStringNums(beatRitmoParts.size()-1) @=> string beatRitmoTags[]; */
Util.concatStrings([
    ["trig", "trigpitch", "pitch", "pitchOffset", "noteLengthMultiplier", "noteTimeMul"]
    /* ,Util.prefixStrings("beatRitmo", beatRitmoTags) */
])
  @=> string rowTags[];


class Row{
  ModuckP outs;
  ModuckP bufUI;
  ModuckP pitchLockUI;
  ModuckP pitchShiftUI;
  /* ModuckP beatRitmoUI; */
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
  /* 
   ThingAndBuffer.make(mk(Repeater), P_Trigger, QUANTIZATION)
     @=> ThingAndBuffer beatRitmoSrc;
   */

  /* 
   def(beatRitmo, makeBeatRitmo());
   def(beatRitmoStacker, mk(Stacker));
   def(beatRitmoRouter, mk(Router, 0));
   */

  /* 
   for(0=>int tagInd;tagInd<beatRitmoTags.size();++tagInd){
     10::ms => now;
     beatRitmoTags[tagInd] @=> string tag;
     ret.input
       => frm("beatRitmo"+tagInd).c
       => beatRitmoStacker.to(tagInd).c;
     
     beatRitmoRouter
       => frm(tagInd).c
       => beatRitmo.to(tagInd).c;
   }
   */

  /* 
   beatRitmoStacker
     => frm(P_Source).c
     => beatRitmoSrc.connector.c
     => beatRitmoRouter.to("index").c;
   beatRitmoSrc.connector => beatRitmoRouter.to(P_Trigger).c;
   beatRitmoStacker
     => MBUtil.onlyLow().c
     => beatRitmoSrc.connector.c;
   */


  /* 
   beatRitmo
     => mk(SampleHold, D16).c
     => notes.connector.c;
   */


  ret.input => frm("trigpitch").c => pitchLock.connector.c;
  ret.input => frm("pitch").c => pitchLock.connector.c;
  ret.input => frm("trig").c => mk(TrigValue, 0).c => notes.connector.c;
  ret.input => frm("pitchOffset").c => pitchShift.connector.c;
  ret.input => frm("trigpitch").c => mk(TrigValue, 0).c => notes.connector.c;
  ret.input => frm("noteLengthMultiplier").c => notes.buf.to("lengthMultiplier").c;
  ret.input => frm("noteTimeMul").c => notes.buf.to("timeMul").c;
  ret.input => frm("noteTimeMul").c => pitchLock.buf.to("timeMul").c;

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
  /* beatRitmoSrc.bufUI @=> ret.beatRitmoUI; */

  /* def(bufClock, mk(PulseDiv, 2)); */

  /* def(backNudgeVal, mk(TrigValue, 90)); */
  /* def(forwardNudgeVal, mk(TrigValue, 110)); */
  /* def(scalingProxy, mk(Prio)); */

  /* 
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

   scalingProxy => bufClock.to("scaling").c;
   */

  /* clockIn */
    /* .b(mk(PulseGen, 2, Runner.timePerTick()/2) => bufClock.c) */
    /* .b(bufClock) */

  /* bufClock */
  clockIn
    .b(notes.connector.to(P_Clock))
    .b(pitchLock.connector.to(P_Clock))
    /* .b(beatRitmoSrc.connector.to(P_Clock)) */
    /* .b(beatRitmo.to(P_Clock)); */
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
    10::ms => now; // Keep JACK happy, prevents getting killed because of buffer underrun
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

def(apc1, mk(Wrapper, 
    apcToLaunchadAdapterOut(mk(NoteOut, openOut(MIDI_OUT_APC), 0, true))
    ,apcToLaunchadAdapterIn(mk(MidInp, MIDI_IN_APC, 0))
));
def(apc2, mk(Wrapper, 
    apcToLaunchadAdapterOut(mk(NoteOut, openOut(MIDI_OUT_APC1), 0, true))
    ,apcToLaunchadAdapterIn(mk(MidInp, MIDI_IN_APC1, 0))
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
  => beatRitmoHolder.c
  => rowCol.keysIn.to("trig").c;


// OUTPUTS


openOut(MIDI_OUT_MICROBRUTE) @=> MidiOut brute;
openOut(MIDI_OUT_MS_20) @=>  MidiOut ms20;
openOut(MIDI_OUT_USB_MIDI) @=> MidiOut nocoast;
openOut(MIDI_OUT_SYS1) @=> MidiOut sys1;


// MAPPINGS


circuitKeyboard => frm("cc80").c => beatRitmoTimeSrc.c;

def(controlsResetOut, mk(Repeater));
controlsResetOut => rowMultiControl("noteLengthMultiplier", circuitKeyboard, "cc81", 1, 300, 100).c;
controlsResetOut => rowMultiControl("noteTimeMul", circuitKeyboard, "cc82", 1, 300, 100).c;

// Reset controller values
(apc1 => frm("cc104").c)
  .b(mk(TrigValue, 100) => rowCol.keysIn.to("noteLengthMultiplier").c)
  .b(mk(TrigValue, 100) => rowCol.keysIn.to("noteTimeMul").c)
  .b(controlsResetOut);


fun ModuckP rowMultiControl(string rowInputTag, ModuckP src, string keyTag, int minVal, int maxVal, int startVal){
  src => frm(keyTag).c
    => mk(RangeMapper, 0, 127, 1, 300).c
    => rowCol.keysIn.to(rowInputTag).c;

  ModuckP sources[0];
  for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
    sources <<
      (rowCol.rows[rowInd].input
      => frm(recv(rowInputTag)).c
      => MBUtil.onlyHigh().c
    );
  }

  def(val, mk(Value, 0).set("triggerOnSet", true));

  rowCol.rowIndexSelector => multiSwitcher(true, sources, [P_Trigger], 
    mk(RangeMapper, minVal, maxVal, 0, 127)
    => val.to(P_Set).c
    => src.to(keyTag).c
  ).c;

  for(0=>int i;i<ROW_COUNT;++i){
    rowCol.rows[i].input.doHandle(rowInputTag, startVal);
  }
  return val;
}



setupOutputSelection();
setupBeatRitmoUI(clock, launchpad, beatRitmo);

// Use one button to start/stop both trig and pitch buffer
def(trigAndPitchBufRouter, mk(Router, 0));
apc2
  => frm("cc104").c
  => trigAndPitchBufRouter.c;
// Match index of row
rowCol.rowIndexSelector => trigAndPitchBufRouter.to("index").c;


apc2
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

keyboard => frm("note").c => rowCol.keysIn.to("trigpitch").c;
circuitKeyboard => frm("note").c
  => mk(Offset, -4*12).c
  => rowCol.keysIn.to("trigpitch").c;

def(trigPitchToggle, mk(Toggler, false));

trigPitchToggle => LP.green().c => launchpad.to("cc104").c;
launchpad => frm("cc104").c => mk(Bigger, 0).c => trigPitchToggle.to(P_Toggle).c;


Scales.MinorNatural.size() => int scaleNoteCount;
launchpadKeyboard(launchpad, 0, 5, scaleNoteCount) @=> ModuckP triggerKeyboard;
triggerKeyboard
  => iff(trigPitchToggle, P_Trigger)
    .then(rowCol.keysIn.to("pitch"))
    .els(rowCol.keysIn.to("trigpitch")).c;
launchpadKeyboard(launchpad, 5, 8, scaleNoteCount) => mk(Offset, -7).c => rowCol.keysIn.to("pitchOffset").c;


ModuckP rowOutputs[0];
for(0=>int rowInd;rowInd<ROW_COUNT;++rowInd){
  rowOutputs <<
    (rowCol.rows[rowInd].outs
    => frm(recv(P_Trigger)).c
    => mk(NumToOut, Util.range(7*5)).c);
}

rowCol.rowIndexSelector => multiSwitcher(rowOutputs, Util.genStringNums(7*5), triggerKeyboard).c;

fun void setupBeatRitmoUI(ModuckP clockIn, ModuckP controllerSrc, ModuckP ritmo){
  for(0=>int i;i<8;++i){
    def(onceTrig, mk(OnceTrigger));
    clockIn => onceTrig.to(P_Trigger).c;
    (controllerSrc => frm("note"+(7+(7-i)*16)).c)
      .b(
          mk(Repeater)
          => onceTrig.to(P_Set).c
          => MBUtil.onlyHigh().c
          => ritmo.to(i).c
        )
      .b( MBUtil.onlyLow()
          => mk(Inverter, 1).c
          => onceTrig.to(P_Clear).c)
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
  apc2
    .b(frm("cc105").to(mk(Bigger, 0) => bufUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16)).to(bufUI, P_Trigger));

  bufUI => apc2.to("note"+(16*rowId)).c;


  def(pitchLockUI, rowCol.rows[rowId].pitchLockUI);
  apc2
    .b(frm("cc105").to(mk(Bigger, 0) => pitchLockUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+1)).to(pitchLockUI, P_Trigger));

  pitchLockUI => apc2.to("note"+(16*rowId+1)).c;


  def(pitchShiftUI, rowCol.rows[rowId].pitchShiftUI);
  apc2
    .b(frm("cc105").to(mk(Bigger, 0) => pitchShiftUI.to(P_ClearAll).c))
    .b(frm("note"+(rowId*16+2)).to(pitchShiftUI, P_Trigger));

  pitchShiftUI => apc2.to("note"+(16*rowId+2)).c;

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
    return mk(Repeater)
      => mk(Mapper, Scales.MinorNatural, 12).c
      => octaves(3).c;
}

function void setupRowOutputs(Row row){
  row.outs
    .b(frm(0).to(mk(Offset, 60) => mk(NoteOut,circuitDeviceOut,9).c)) // Drums
    .b(frm(1).to(outPitchQuant() => mk(NoteOut,circuitDeviceOut,0).c))
    .b(frm(2).to(outPitchQuant() => mk(NoteOut,nocoast,0).c))
    .b(frm(3).to(outPitchQuant() => mk(NoteOut,brute,0).c))
    .b(frm(4).to(outPitchQuant() => mk(NoteOut,ms20,0).c))
    .b(frm(5).to(outPitchQuant() => mk(NoteOut,sys1,0).c))
  ;
}


function void setupOutputSelection(){
  for(0=>int rowInd;rowInd<rowCol.rows.size();++rowInd){
    // Select outputs with side buttons
    8+rowInd*16 => int ind;
    apc1
      => mk(Bigger,0).from("note"+ind).c
      => mk(TrigValue,rowInd).c
      => rowCol.rowIndexSelector.to(P_Set).c
    ;

    rowCol.rowIndexSelector
      => MBUtil.onlyHigh().c
      => mk(Processor, Eq.make(rowInd)).c
      => mk(TrigValue, rowInd).c
      => LP.red().c
      => apc1.to("note"+ind).c;
  }
}


function void makeOutsUIRow(int rowId){
  for(0=>int outputId;outputId<OUT_DEVICE_COUNT;++outputId){
    def(outs, rowCol.rows[rowId].outs);
    apc1
      => frm("note"+(rowId*16+outputId)).c
      => outs.to("toggleOut"+outputId).c;

    outs
      => frm("outActive"+outputId).c
      => LP.red().c
      => apc1.to("note"+(rowId*16+outputId)).c;
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

