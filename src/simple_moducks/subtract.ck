

include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      parent.send(P_Trigger, IntRef.make(parent.getVal("a") - parent.getVal("b")));
    }
  },
)

public class Subtract extends Moduck{
  maker0(Subtract){
    Subtract ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("a", 0);
    ret.addVal("b", 0);

    Patch.connect(ret, recv("a"),
      Patch.connect(Delay.make(samp), P_Default, ret, P_Trigger)
    ,P_Trigger);

    Patch.connect(ret, recv("b"),
      Patch.connect(Delay.make(samp), P_Default, ret, P_Trigger)
    ,P_Trigger);

    return ret;
  }
}
