
3 => int DEVICE_PORT;
0 => int MIDI_PORT;

fun Handler V(Handler src, Handler target, string msg){
  return Patch.connVal(src, null, target, msg);
}

fun Handler V1(Handler src, string srcEventName, Handler target, string msg){
  return Patch.connVal(src, srcEventName, target, msg);
}

fun  Handler C(Handler src, Handler target){
  return Patch.connect(src, null, target, null);
}

fun  Handler C1(Handler src, Handler target, string msg){
  return Patch.connect(src, null, target, msg);
}

fun  Handler C2(Handler src, string srcEventName, Handler target, string msg){
  return Patch.connect(src, srcEventName, target, msg);
}

fun ChainData X(Handler target){
  return ChainData.conn(null, target, null);
}

fun ChainData X1(Handler target, string targetTag){
  return ChainData.conn(null, target, targetTag);
}

fun ChainData X2(string srcTag, Handler target, string targetTag){
  return ChainData.conn(srcTag, target, targetTag);
}

fun ChainData XV(Handler target, string targetTag){
  return ChainData.val(null, target, targetTag);
}


fun ChainData XV1(string srcTag, Handler target, string targetTag){
  return ChainData.val(srcTag, target, targetTag);
}


fun void CM(Handler src, ChainData targets[]){
  return Patch.connectMulti(src, targets);
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


Trigger startBang;
ClockGen.make(BPM * TICKS_PER_BEAT) @=> ClockGen clock;


// Connect clock to start bang
C1(startBang, clock, "run");

Sequencer.make([70, 72, 74, 76], true) @=> Sequencer noteSeq;
Sequencer.make(Util.ratios(0, 127, [1.0, .7, .6]), true) @=> Sequencer durationSeq;
Sequencer.make([B2, B2, B2, B4, B4, B4, B2], true) @=> Sequencer noteDivSeq;

PulseDiv.make(0) @=> PulseDiv divider;
V(noteDivSeq, divider, "denom");

CM( C(clock, divider), [
  X(noteSeq)
  ,X(noteDivSeq)
  ,X(durationSeq)
]);


NoteOut.make(DEVICE_PORT, MIDI_PORT, 0::ms, TIME_PER_BEAT/2)
  @=> NoteOut noteOut;

V(durationSeq, noteOut, "ratio");

/* 
 Patch.chain(clock, [
   X(PulseDiv.make(1))
   ,X(Sequencer.make(Util.concat([Util.range(127,0,1), Util.range(0,127,1)]), true))
   ,XV(noteOut, "ratio")
 ]);
 */

C1(noteSeq, noteOut, "note");

/* Patch.chain(offsetSeq, [ */
/*   X(Delay.make(80::ms)) */
/*   ,X1(noteOut, "note") */
/* ]); */
/*  */

// Stuff
ms  => now;
startBang.trigger("start", 1);

while(true) { 99::hour => now; }
