include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger,
  now => time lastTriggerTime;
  HANDLE{
    if(v == null){
      parent.send(P_Trigger, null);
    }else if(now- lastTriggerTime >= parent.getVal("tolerance")::samp){
      parent.send(P_Trigger, v);
      now => lastTriggerTime;
    }
  },
;
)

public class Throttler extends Moduck{
  maker(Throttler, dur tolerance){
    Throttler ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("tolerance", Util.toSamples(tolerance));
    return ret;
  }
}
