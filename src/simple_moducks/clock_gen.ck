include(moduck_macros.m4)

class Shared{
  int bpm;
  false => int running;
}
fun void loop(ModuckBase parent, Shared shared){
  while(true){
    parent.sendPulse(P_Clock, 0);
    if(shared.running){
      minute / shared.bpm => now;
    }else{
      break;
    }
  }
}
genHandler(GateHandler, P_Gate, 
    Shred @ looper;

    HANDLE{
      if(looper != null){
        looper.exit();
        null @=> looper;
      }
      (v != null) => shared.running;
      if(shared.running){
        spork ~ loop(parent, shared) @=> looper;
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
