
fun Handler V(Handler src, string srcEventName, Handler target, string msg){
  return Patch.connVal(src, srcEventName, target, msg);
}

fun  Handler C(Handler src, string srcEventName, Handler target, string msg){
  return Patch.connect(src, srcEventName, target, msg);
}




Trigger startBang;
ClockGen clock;
Printer.make("Seq event") @=> Printer printer;
Sequencer.make([5,3,6,1]) @=> Sequencer seq;
Delay.make(2.4::second) @=> Delay delay;

// Start sequencer and delay
C(startBang, null, clock, "run");
C(startBang, null, delay, "delay");

// Step sequencer each clock
C(clock, null, seq, "step");

// Set sequencer loop to false when delay triggers
V(
  C(delay, null, Value.make(false), null)
  ,"", seq, "loop"
);

C(seq, null, printer, "print"); // Print each sequencer step


ms  => now;
startBang.trigger("start", 1);

while(true) { 100::ms => now; }
