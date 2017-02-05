
3 => int DEVICE_PORT;
0 => int MIDI_PORT;


// Aliases

fun Moduck V(Moduck src, Moduck target, string msg){
  return Patch.connVal(src, null, target, msg);
}

fun Moduck V1(Moduck src, string srcEventName, Moduck target, string msg){
  return Patch.connVal(src, srcEventName, target, msg);
}

fun  Moduck C(Moduck src, Moduck target){
  return Patch.connect(src, null, target, null);
}

fun  Moduck C1(Moduck src, Moduck target, string msg){
  return Patch.connect(src, null, target, msg);
}

fun  Moduck C2(Moduck src, string srcEventName, Moduck target, string msg){
  return Patch.connect(src, srcEventName, target, msg);
}

fun ChainData X(Moduck target){
  return ChainData.conn(null, target, null);
}

fun ChainData X1(Moduck target, string targetTag){
  return ChainData.conn(null, target, targetTag);
}

fun ChainData X2(string srcTag, Moduck target, string targetTag){
  return ChainData.conn(srcTag, target, targetTag);
}

fun ChainData XV(Moduck target, string targetTag){
  return ChainData.val(null, target, targetTag);
}

fun ChainData XV1(string srcTag, Moduck target, string targetTag){
  return ChainData.val(srcTag, target, targetTag);
}

fun Moduck multi(Moduck src, ChainData targets[]){
  return Patch.connectMulti(src, targets);
}

fun Sequencer seq(int ents[]){
  return Sequencer.make(ents, true);
}

fun Moduck chain(Moduck first, ChainData rest[]){
  return Patch.chain(first, rest);
}

//  End of aliases

fun Moduck noteDiddler(dur maxNoteDur, int notes[], int noteValues[], int noteDivs[], float durationRatios[], Moduck noteProcessor){
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

  NoteOut.make(DEVICE_PORT, MIDI_PORT, 0::ms, maxNoteDur)
    @=> NoteOut noteOut;

  V(durationSeq, noteOut, "durRatio");

  Moduck @ out;

  if(noteProcessor != null){
    C(noteProcessor, noteOut) @=> out;
  }else{
    noteOut @=> out;
  }

  chain(divClock, [
    X(noteSeq)
    ,X(Mapper.make(noteValues, 12))
    ,X1(out, "note")
  ]);

  return parent;
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


fun void _body(Moduck clock){
  noteDiddler(TIME_PER_BEAT/2
    ,[0,1,2,3]
    ,[70, 72, 74, 76]
    ,[B2, B2, B2, B4, B4, B4, B2]
    ,[1.0, .7, .6]
    ,null
  );
}

fun void __body(Moduck clock){
  Scales.Major @=> int noteVals[];
  68 => int rootNote;

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
}


fun void scaleTest(Moduck clock){
  72 => int rootNote;
  C(clock, noteDiddler(TIME_PER_BEAT/4
    ,[-7, -9, -10, -11, -10, -9, -8, -7, -4, -2, 0,1,2,3,4,5,6,7,8, 9]
    ,Scales.MinorHarmonic
    ,[B]
    ,[1.0]
    ,C(Offset.make(rootNote), Printer.make(""))
  ));
}

fun void dualMelo(Moduck clock){

  // Create note output module, outputting notes between 0 and 500ms
  NoteOut.make(DEVICE_PORT, MIDI_PORT, 0::ms, 500::ms)
    @=> NoteOut noteOut;

  // Connect two looping sequencers to a clock
  multi(clock, [
      X(chain(PulseDiv.make(3, true),[ // Divide clock so this triggeres every third pulse
          X(Sequencer.make([62, 63, 65], true)) // Three notes, looping
          ,X(noteOut)
      ]))
      ,X(C(Sequencer.make([60], true), noteOut)) // Play note 60 every clock tick
    ]
  );
}


fun void routerTest(Moduck clock, NoteOut noteOut){
  seq([68,65,63]) @=> Sequencer s1;
  seq([60,62,64]) @=> Sequencer s2;
  seq([0,1]) @=> Sequencer indexer;

  Router.make(1) @=> Router router;

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
  ]);
}


fun void body(Moduck clock, NoteOut noteOut){
  routerTest(clock, noteOut);
}

fun void setup(){
  Trigger startBang;
  ClockGen.make(BPM) @=> ClockGen masterClock;
  NoteOut.make(DEVICE_PORT, MIDI_PORT, 0::ms, TIME_PER_BEAT/2)
    @=> NoteOut noteOut;

  body(masterClock, noteOut);

  C1(startBang, masterClock, "run");
  samp  => now;
  startBang.trigger("start", 1);
}


setup();
while(true) { 99::hour => now; }
