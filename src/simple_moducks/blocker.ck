
include(macros.m4)

genHandler(GateHandler, P_Gate, 
  HANDLE{
    (null != v) => active.i;
    if(parent.getVal("offFromGate") && v==null){
      parent.send(P_Trigger,null);
    }
  },
  IntRef active;
)


genHandler(TrigHandler, P_Trigger, 
  HANDLE{
    if(active.i){
      parent.send(P_Trigger, v);
    }
  },
  IntRef active;
)


public class Blocker extends Moduck{
  maker(Blocker, int offFromGate){
    Blocker ret;
    IntRef active;
    false => active.i;
    OUT(P_Trigger);
    IN(TrigHandler, (active));
    IN(GateHandler, (active));
    ret.addVal("offFromGate", offFromGate);
    return ret;
  }

  fun static Blocker make(){
    return make(false);
  }
}
