
fun Handler V(Handler src, string srcEventName, Handler target, string msg){
  return Patch.connVal(src, srcEventName, target, msg);
}

fun  Handler C(Handler src, string srcEventName, Handler target, string msg){
  return Patch.connect(src, srcEventName, target, msg);
}

fun ChainData X(string srcTag, Handler target, string targetTag){
  return ChainData.conn(srcTag, target, targetTag);
}

fun ChainData XV(string srcTag, Handler target, string targetTag){
  return ChainData.val(srcTag, target, targetTag);
}


Trigger startBang;
ClockGen clock;
Delay.make(2.4::second) @=> Delay delay;

// Connect clock and delay to start event
C(startBang, null, clock, "run");
C(startBang, null, delay, "delay");

Sequencer.make([5,3,6,1]) @=> Sequencer seq;

Patch.chain(clock, [
  X(null, seq, "step")
  ,X(null, Offset.make(10), null)
  ,X(null, Printer.make("Seq Event"), "print")
]);

// Set sequencer loop to false when delay triggers
Patch.chain(delay, [
  X(null, Value.False(), null)
  ,XV(null, seq, "loop")
]);



// Stuff
ms  => now;
startBang.trigger("start", 1);

while(true) { 100::ms => now; }
