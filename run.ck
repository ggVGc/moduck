
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
8 => int TICKS_PER_BEAT;


Trigger startBang;
ClockGen.make(BPM * TICKS_PER_BEAT) @=> ClockGen clock;


// Connect clock to start bang
C1(startBang, clock, "run");

Sequencer.make([70, 72, 74, 76]) @=> Sequencer noteSeq;
Sequencer.make([5, 2, 1, 1, 2, 3, 4, 5]) @=> Sequencer noteDivSeq;

PulseDiv.make(0) @=> PulseDiv divider;
V(noteDivSeq, divider, "denom");

CM( C(clock, divider), [
  X(noteSeq)
  ,X(noteDivSeq)
]);


NoteOut.make(DEVICE_PORT, MIDI_PORT, 100::ms)
  @=> NoteOut noteOut;

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
