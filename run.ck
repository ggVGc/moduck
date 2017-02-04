
1 => int DEVICE_PORT;
0 => int MIDI_PORT;

fun Handler V(Handler src, string srcEventName, Handler target, string msg){
  return Patch.connVal(src, srcEventName, target, msg);
}

fun  Handler C(Handler src, string srcEventName, Handler target, string msg){
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

fun ChainData XV(string srcTag, Handler target, string targetTag){
  return ChainData.val(srcTag, target, targetTag);
}


Trigger startBang;
ClockGen.make(240) @=> ClockGen clock;
Delay.make(130::second) @=> Delay delay;


// Connect clock and delay to start event
C(startBang, null, clock, "run");
C(startBang, null, delay, "delay");

/* Sequencer.make([50, 54, 53, 59, 55]) */
Sequencer.make([45, 45, 45, 45])
  @=> Sequencer seq;


Patch.chain(clock, [
  X1(seq, "step")
  ,X(Offset.make(20)) 
]) 
  @=> Handler offsetSeq;


/* C(seq, null, Printer.make("Seq Event"), "print"); */
/* C(offsetSeq, null, Printer.make("Offset Seq Event"), "print"); */



// Set sequencer loop to false when delay triggers
Patch.chain(delay, [
  X(Value.False())
  ,XV(null, seq, "loop")
]);

NoteOut.make(DEVICE_PORT, MIDI_PORT) @=> NoteOut noteOut;

Util.setValRef(noteOut, "duration", Util.toSamples(100::ms));

C(seq, null, noteOut, "note");
/* Patch.chain(offsetSeq, [ */
/*   X(Delay.make(80::ms)) */
/*   ,X1(noteOut, "note") */
/* ]); */
/*  */

// Stuff
ms  => now;
startBang.trigger("start", 1);

while(true) { 99::hour => now; }
