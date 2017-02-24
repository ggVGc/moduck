include(macros.m4)


genHandler(TrigHandler, P_Trigger,

  fun void doTriggers(int count, dur wait, int val){
    for(0=>int i;i<count;i++){
      parent.send(P_Trigger, val);
      wait => now;
    }
  }

  HANDLE{
    spork ~ doTriggers(parent.getVal("count"), parent.getVal("delta")::samp, v);
  },
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
  },
)

public class PulseGen extends Moduck{
  fun static PulseGen make(int repeatCount, dur delta){
    PulseGen ret;
    OUT(P_Trigger);
    IN(TrigHandler,());
    IN(ResetHandler,());
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
