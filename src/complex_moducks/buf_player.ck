include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)



// Play buffer when gate is on.
// Use timeToNext for waits between entries


fun void runLoop(Event startBang, IntRef running, Buffer buf){
  while(true){
    if(running.i){
      buf.timeToNext() => now;
      buf.doHandle(P_Clock, IntRef.yes());
    }else{
      startBang => now;
      buf.doHandle(P_Clock, IntRef.yes());
    }
  }
}


genHandler(GateHandler, P_Gate,
  IntRef.make(false) @=> IntRef running;
  Event startBang;

  fun void init(){
    spork ~ runLoop(startBang, running, buf) @=> Shred looper;
  }
  HANDLE{
    running.i => int wasRunning;
    v != null => running.i;
    if(running.i && !wasRunning){
      startBang.broadcast();
    }
  },
  Buffer buf;
)



public class BufPlayer extends Moduck{
  fun static Moduck make(Buffer buf){
    Moduck ret;

    OUT(P_Trigger);
    IN(GateHandler, (buf));
    /* IN(ResetHandler, ()); */
    /* OUT(P_Looped); */

    return ret;
  }
}


