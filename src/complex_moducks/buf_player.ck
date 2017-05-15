include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)



// Play buffer when gate is on.
// Use timeToNext for waits between entries


fun void runLoop(IntRef running, Buffer buf){
  while(true){
    if(running.i){
      buf.timeToNext() => now;
      samp => now;
      buf.doHandle(P_Clock, IntRef.yes());
    }else{
      break;
    }
  }
}


genHandler(GateHandler, P_Gate,
  Shred @ looper;
  IntRef.make(false) @=> IntRef running;
  
  HANDLE{
    if(looper != null){
      looper.exit();
      null @=> looper;
    }
    v != null => running.i;
    if(running.i){
      buf.doHandle(P_Clock, IntRef.yes());
      spork ~ runLoop(running, buf) @=> looper;
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


