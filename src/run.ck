
/* 
 2 => int DEVICE_PORT;
 0 => int MIDI_PORT;
 */

include(midiPorts.m4)

include(aliases.m4)

fun Moduck noteDiddler(int port, dur maxNoteDur, int notes[], int noteValues[], int noteDivs[], float durationRatios[], Moduck noteProcessor){
  Repeater.make() @=> Repeater parent;
  
  Sequencer.make(notes, true) @=> Sequencer noteSeq;
  Sequencer.make(noteDivs, true) @=> Sequencer noteDivSeq;
  Util.ratios(0, 127, durationRatios) @=> int durations[];
  Sequencer.make(durations, true) @=> Sequencer durationSeq;

  PulseDiv.make(durations[0], true) @=> PulseDiv divider;
  V(noteDivSeq, divider, "divisor");
  C(parent, divider) @=> Moduck divClock;

  multi( divClock, [
    X(noteDivSeq)
    ,X(durationSeq)
  ]);

  NoteOut.make(port, 0, 0::ms, maxNoteDur)
    @=> NoteOut noteOut;

  V(durationSeq, noteOut, "durRatio");

  Moduck @ out;

  if(noteProcessor != null){
    C(noteProcessor, noteOut) @=> out;
  }else{
    noteOut @=> out;
  }


  return Wrapper.make(parent, 
    chain(divClock, [
      X(noteSeq)
      ,X(Mapper.make(noteValues, 12))
      ,X(out)
    ]));
}


120 => int BPM;
32 => int TICKS_PER_BEAT;
Util.bpmToDur(BPM) => dur TIME_PER_BEAT;

TICKS_PER_BEAT => int B;
TICKS_PER_BEAT /2 => int B2;
TICKS_PER_BEAT / 4 => int B4;
TICKS_PER_BEAT / 8 => int B8;
TICKS_PER_BEAT / 16 => int B16;
TICKS_PER_BEAT / 32 => int B32;





fun void song1(Moduck startBang, Moduck clock, Moduck _){
  /* Scales.Major @=> int scale[]; */
  TIME_PER_BEAT/2 => dur maxNoteLen;

  Offset.make(-12) @=> Offset offsetter;

  noteDiddler(0, maxNoteLen, 
    [1,3,5,3,4,2,6,4]
    ,[10]
    ,[B2]
    ,[1.0]
    ,C(offsetter, Offset.make(6))
  ) @=> Moduck melo;


  noteDiddler(MIDI_OUT_ZYNADDSUBFX, maxNoteLen, 
    [1,3,5,3,4,2,6,4]
    ,[10]
    ,[B4]
    ,[1.0]
    ,offsetter
  ) @=> Moduck bass;

  chain(clock, [
    X(PulseDiv.make(B2*2, true))
    /* ,X(seq([-12, -12, -15, -9])) */
    ,X(seq([-12, -12, -12, -12, -10, -9, -7, -14]))
    ,XV(offsetter, "offset")
  ]);
  


  C(multi(clock,[X(bass), X(melo)]), Printer.make(""));
}












































fun void _body(Moduck clock){
  /* 
   noteDiddler(TIME_PER_BEAT/2
     ,[0,1,2,3]
     ,[70, 72, 74, 76]
     ,[B2, B2, B2, B4, B4, B4, B2]
     ,[1.0, .7, .6]
     ,null
   );
   */
}

fun void __body(Moduck clock){
  Scales.Major @=> int noteVals[];
  68 => int rootNote;

  /* 
   multi(clock, [
     X(noteDiddler(TIME_PER_BEAT/8
       ,[2]
       ,noteVals
       ,[B]
       ,[1.0]
       ,Offset.make(rootNote)
     ))
     ,X(noteDiddler(TIME_PER_BEAT/8
       ,[1]
       ,noteVals
       ,[B]
       ,[1.0]
       ,C(Offset.make(rootNote), Delay.make(30::ms))
     ))
     ,X(noteDiddler(TIME_PER_BEAT/8
       ,[3]
       ,noteVals
       ,[B, B4, 3 * B, B2, B4, B2]
       ,[1.0]
       ,Offset.make(rootNote-12)
     ))
     ,X(noteDiddler(TIME_PER_BEAT/8
       ,[1,3,2,5]
       ,noteVals
       ,[B2* 3]
       ,[.2, .3, .4, .5, .6, .8, .9, .1, .2]
       ,Offset.make(rootNote+14)
     ))
   ]);
   */
}


fun void scaleTest(Moduck clock){
  72 => int rootNote;
  C(clock, noteDiddler(0, TIME_PER_BEAT/4
    ,[-7, -9, -10, -11, -10, -9, -8, -7, -4, -2, 0,1,2,3,4,5,6,7,8, 9]
    ,Scales.MinorHarmonic
    ,[B]
    ,[1.0]
    ,C(Offset.make(rootNote), Printer.make(""))
  ));
}

fun void dualMelo(Moduck clock, NoteOut noteOut){
  // Connect two looping sequencers to a clock

  Sequencer.make([60, 58], true) @=> Sequencer s;

  multi(clock, [
     X(chain(PulseDiv.make(3, true),[ // Divide clock so this triggeres every third pulse
         X(Sequencer.make([66, 67, 69], true)) // Three notes, looping
         ,X(noteOut)
     ]))
     ,X(C2(s, Pulse.Stepped(), noteOut, null)) // Play note 60 every clock tick
    ]
  );

  C2(s, Pulse.Looped(), Printer.make("Looped"), null);

  chain(C(clock, PulseDiv.make(99999999, true)), [
    X(Delay.make(2::second))
    ,X(Value.make(50))
    ,X1(s, Pulse.Set())
    ,X2(Pulse.Set(), Delay.make(5::second), null) // will keep triggering, but doesn't matter
    ,X(Value.make(55))
    ,X1(s, Pulse.Set())
  ]);
}

fun void testConnectDouble(Moduck clock, NoteOut noteOut){
  Sequencer.make([60, 62], true) @=> Sequencer s;

  C(clock, s);


 chain(C(clock, PulseDiv.make(10000, true)), [
   X(Delay.make(2::second))
   ,X(Value.make(50))
   ,X1(s, Pulse.Set())
 ]);
}



fun void routerTest(Moduck clock, NoteOut noteOut){
  seq([68,65,63]) @=> Sequencer s1;
  seq([60,62,64]) @=> Sequencer s2;
  seq([0,1]) @=> Sequencer indexer;

  Router.make(1) @=> Router router;

  MUtil.combine([MUtil.mul2(s1, s2), MUtil.add2(s1, s2)]) @=> Moduck combined;
  C(combined, Printer.make("")) @=> Moduck mult;

  // Send router output to sequencers, and finally to noteOut
 chain(
   multi(router,[
     X2("0", s1, null) // Connect s1 to router index 0
     ,X2("1", s2, null) // Connect s2 to router index 1
   ])
   , [X(noteOut)]
 );

 multi(clock,[
   // Send pulses, divided by 6, to sequencer controlling router index
   X(chain(PulseDiv.make(6, false), [
       X(indexer)                    
       ,XV(router, "index")
     ]
   ))
   ,X( router ) // Send pulses to router to be forwarded to active sequencer
   ,X(combined)
 ]);
}


fun void body(Moduck startBang, Moduck clock, NoteOut noteOut){
  /* routerTest(clock, noteOut); */
  /* song1(startBang, clock, noteOut); */
  /* testConnectDouble(clock, noteOut); */
  dualMelo(clock, noteOut);
}


fun void setup(){
  Trigger.make("start") @=> Trigger startBang;
  /* ClockGen.make(Util.bpmToDur(BPM)) */
  /* ClockGen.make(Util.bpmToDur( BPM * TICKS_PER_BEAT)) */
  ClockGen.make(Util.bpmToDur( BPM ))
    @=> ClockGen masterClock;

  NoteOut.make(MIDI_OUT_ZYNADDSUBFX, 0, 200::ms, TIME_PER_BEAT/2)
    @=> NoteOut noteOut;

  body(startBang, masterClock, noteOut);

  C2(startBang, "start", masterClock, "run");

  /* 
   chain(masterClock,[
     X(Sequencer.make([70,74,76],true))
     ,X(Repeater.make())
     ,X(noteOut)
   ]);
   */

  /* 
   C(masterClock, noteDiddler(MIDI_OUT_ZYNADDSUBFX, 100::ms, 
     [1,3,5,3,4,2,6,4]
     ,[10]
     ,[B2]
     ,[1.0]
     ,null
   ));
   */

  100::samp  => now;
  startBang.trigger(1);
}


setup();
while(true) { 99::hour => now; }
