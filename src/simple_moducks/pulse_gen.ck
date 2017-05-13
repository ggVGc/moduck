include(moduck_macros.m4)


genHandler(TrigHandler, P_Trigger,
  fun void doTriggers(int count, dur wait, int val){
    for(0=>int i;i<count;i++){
      parent.sendPulse(P_Trigger, val);
      if(quit.i){
        false => quit.i;
        return;
      }
      wait => now;
    }
  }

  HANDLE{
    if(null != v){
      spork ~ doTriggers(parent.getVal("count"), parent.getVal("delta")::samp, v.i);
    }
  },
  IntRef quit;
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    true => quit.i;
  },
  IntRef quit;
)

public class PulseGen extends Moduck{
  fun static PulseGen make(int repeatCount, dur delta){
    PulseGen ret;
    IntRef quit;
    false => quit.i;
    OUT(P_Trigger);
    IN(TrigHandler,(quit));
    IN(ResetHandler,(quit));
    ret.addVal("count", repeatCount);
    ret.addVal("delta", Util.toSamples(delta));
    return ret;
  }

  fun static Moduck[] many(int count, int repeatCount, dur delta){
    Moduck ret[count];
    for(0=>int x;x<count;++x){
      make(repeatCount, delta) @=> ret[x];
    }
    return ret;
  }
}
