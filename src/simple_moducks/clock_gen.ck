include(moduck_macros.m4)

class Shared{
  int bpm;
  false => int running;
}

fun void runLoop(ModuckBase parent, IntRef running, Shared shared){
  while(true){
    minute / shared.bpm => now;
    if(running.i){
      parent.sendPulse(P_Clock, 0);
    }else{
      break;
    }
  }
}


genHandler(GateHandler, P_Gate, 
    IntRef running;
    Shred @ loopShred;

  HANDLE{
    if(loopShred != null){
      false => running.i;
      loopShred.exit();
      null @=> loopShred;
    }
    if(v != null){
      IntRef.make(true) @=> running;
      parent.sendPulse(P_Clock, 0);
      spork ~ runLoop(parent, running, shared) @=> loopShred;
    }
  },
  Shared shared;
)



/* 
 genHandler(BpmHandler, "bpm",
   HANDLE{
     if(null != v){
       parent.setVal("delta", Util.toSamples(Util.bpmToDur(v.i)));
     }
   },
 )
 */

public class ClockGen extends Moduck{
  Shared shared;

  fun void setBpm(int bpm){
    bpm => shared.bpm;
  }

  fun int getBpm(){
    return shared.bpm;
  }
    


  fun static ClockGen make(int bpm){
    ClockGen ret;
    bpm => ret.shared.bpm;
    OUT(P_Clock);
    IN(GateHandler, (ret.shared));
    return ret;
  }
}
