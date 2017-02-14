
fun void runForever(){
  while(true) { 99::hour => now; }
}

include(aliases.m4)
include(song_macros.m4)
include(_all_parts.m4)

  120 => int BPM;
32 => int TICKS_PER_BEAT;

define(TIME_PER_BEAT, Util.bpmToDur(`BPM'))

define(B, TICKS_PER_BEAT)
define(B2, B/2)
define(B4, B2/2)
define(B3, B-B4)
define(B5, B+B4)
define(B6, B+B2)
define(B7, B+B2+B4)
define(B8, B4/2)
define(B16, B8/2)
define(B32, B16/2)



Trigger.make("start") @=> Trigger startBang;

Repeater.make() @=> Repeater masterClock;


include(midiPorts.m4)
include(_cur_song)
<<< "=== Song setup done ===">>>;


chain(startBang, [
  X2("start", ClockGen.make(Util.bpmToDur( BPM * TICKS_PER_BEAT)),"run")
  ,X(masterClock)
]);

samp  => now;

startBang.trigger(1);
runForever();


