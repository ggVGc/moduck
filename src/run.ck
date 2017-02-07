

fun void runForever(){
  while(true) { 99::hour => now; }
}



int B;
int B2;
int B4;
int B8;
int B16;
int B32;


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
  samp  => now;
  return startBang;
}

setup().trigger(0);
runForever();


