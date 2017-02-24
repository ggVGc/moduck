include(macros.m4)


genHandler(TrigHandler, P_Trigger,
  fun void doWait(int v){
    parent.getVal("delay") :: samp => now;
    parent.send(P_Trigger, v);
  }
  HANDLE{
    spork ~ doWait(v);
  },
;
)

public class Delay extends Moduck{
  maker(Delay, dur delay){
    Delay ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("delay", Util.toSamples(delay));
    return ret;
  }
}
