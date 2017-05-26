include(moduck_macros.m4)

class Shared{
  int bpm;
  false => int running;
}

fun void runLoop(ModuckBase parent, Event startBang, IntRef running, Shared shared){
  while(true){
    minute / shared.bpm => now;
    if(running.i){
      parent.sendPulse(P_Clock, 0);
    }else{
      startBang => now;
      parent.sendPulse(P_Clock, 0);
    }
  }
}


genHandler(GateHandler, P_Gate, 
    IntRef.make(false) @=> IntRef running;
    Event startBang;
    false => int started;

  HANDLE{
    if(!started){
      true => started;
      spork ~ runLoop(parent, startBang, running, shared);
      parent.sendPulse(P_Clock, 0);
    }
    running.i => int wasRunning;
    v != null => running.i;
    if(running.i && !wasRunning){
      startBang.broadcast();
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
