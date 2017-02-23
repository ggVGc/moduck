include(macros.m4)


genHandler(TrigHandler, P_Trigger,
  Shred @ waiter;
  fun void doWait(int v){
    parent.getVal("delay") :: samp => now;
    /* <<< now >>>; */
    parent.send(P_Trigger, v);
  }
  HANDLE{
    if(waiter != null){
      waiter.exit();
      null @=> waiter;
    }
    spork ~ doWait(v) @=> waiter;
  },
;
)

public class Delay extends Moduck{
  fun static Delay make(dur delay){
    Delay ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("delay", Util.toSamples(delay));
    return ret;
  }
}
