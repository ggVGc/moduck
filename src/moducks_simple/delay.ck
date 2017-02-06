include(macros.m4)


genHandler(TrigHandler, Pulse.Trigger(),
  Shred @ waiter;
  fun void doWait(int v){
    parent.getVal("delay") :: samp => now;
    /* <<< now >>>; */
    parent.send(Pulse.Trigger(), v);
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
    ret.setVal("delay", Util.toSamples(delay));
    OUT(Pulse.Trigger());
    IN(TrigHandler, ());
    return ret;
  }
}
