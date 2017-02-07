fun void runForever(){
  while(true) { 99::hour => now; }
}

include(aliases.m4)
include(_all_parts.m4)

120 => int BPM;
32 => int TICKS_PER_BEAT;

define(TIME_PER_BEAT, Util.bpmToDur(`BPM'))
define(B, TICKS_PER_BEAT)
define(B2, (Math.round((B$float)/2.0)$int))
define(B4, (Math.round((B2$float)/2.0)$int))
define(B8, (Math.round((B4$float)/2.0)$int))
define(B16, (Math.round((B8$float)/2.0)$int))
define(B32, (Math.round((B16$float)/2.0)$int))


fun void body(Moduck startBang, Moduck masterClock){
  include(midiPorts.m4)
  include(_cur_song)
}


fun Trigger setup(){
  Trigger.make("start") @=> Trigger startBang;
  ClockGen.make(Util.bpmToDur( BPM * TICKS_PER_BEAT))
    @=> ClockGen masterClock;

  C2(startBang, "start", masterClock, "run");

  body(startBang, masterClock);
  samp  => now;
  return startBang;
}

setup().trigger(0);
runForever();


