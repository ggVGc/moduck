
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

fun void CM(Moduck src, ChainData targets[]){
  return Patch.connectMulti(src, targets);
}

//  End of aliases

fun void noteDiddler(Moduck clock, dur maxNoteDur, int notes[], int noteDivs[], float durationRatios[]){
  Sequencer.make(notes, true) @=> Sequencer noteSeq;
  Sequencer.make(noteDivs, true) @=> Sequencer noteDivSeq;
  Sequencer.make(Util.ratios(0, 127, durationRatios), true) @=> Sequencer durationSeq;

  PulseDiv.make(0) @=> PulseDiv divider;
  V(noteDivSeq, divider, "divisor");

  CM( C(clock, divider), [
    X(noteSeq)
    ,X(noteDivSeq)
    ,X(durationSeq)
  ]);


  NoteOut.make(DEVICE_PORT, MIDI_PORT, 0::ms, maxNoteDur)
    @=> NoteOut noteOut;

  V(durationSeq, noteOut, "durRatio");

  C1(noteSeq, noteOut, "note");
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
  noteDiddler(
    clock
    ,TIME_PER_BEAT/2
    ,[70, 72, 74, 76]
    ,[B2, B2, B2, B4, B4, B4, B2]
    ,[1.0, .7, .6]
  );
}

fun void body(Moduck clock){

  noteDiddler(clock,TIME_PER_BEAT/8
    ,[62]
    ,[B]
    ,[1.0]
  );


  noteDiddler(clock,TIME_PER_BEAT/8
    ,[65]
    ,[B, B4, 3 * B, B2, B4, B2]
    ,[1.0]
  );

  noteDiddler(clock, TIME_PER_BEAT/8
    ,[70, 69, 72, 78]
    ,[B2 * 3]
    ,[1.0]
  );

}


fun void setup(){
  Trigger startBang;
  ClockGen.make(BPM * TICKS_PER_BEAT) @=> ClockGen masterClock;

  body(masterClock);

  C1(startBang, masterClock, "run");
  ms  => now;
  startBang.trigger("start", 1);
}


setup();
while(true) { 99::hour => now; }
