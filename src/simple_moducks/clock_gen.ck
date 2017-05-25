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

fun void retriggeringRunLoop(ModuckBase parent, Event startBang, IntRef running, Shared shared){
  0::ms => dur accum;
  while(true){
    1::ms => now;
    accum + 1::ms => accum;
    if(running.i){
      if (accum >= (minute / shared.bpm)){
        parent.sendPulse(P_Clock, 0);
        0::ms => accum;
      }
    }else{
      startBang => now;
      parent.sendPulse(P_Clock, 0);
      0::ms => accum;
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
      if(retriggering){
        spork ~ retriggeringRunLoop(parent, startBang, running, shared);
      }else{
        spork ~ runLoop(parent, startBang, running, shared);
      }
      parent.sendPulse(P_Clock, 0);
    }
    running.i => int wasRunning;
    v != null => running.i;
    if(running.i && !wasRunning){
      startBang.broadcast();
    }
  },
  Shared shared;
  int retriggering;
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
    


  fun static ClockGen make(int bpm, int retriggering){
    ClockGen ret;
    bpm => ret.shared.bpm;
    OUT(P_Clock);
    IN(GateHandler, (ret.shared, retriggering));
    return ret;
  }

  fun static ClockGen make(int bpm){
    return make(bpm, false);
  }
}
