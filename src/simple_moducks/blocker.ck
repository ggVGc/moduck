
include(macros.m4)
include(song_macros.m4)

genHandler(GateHandler, P_Gate, 
  HANDLE{
    (null != v) => active.i;
    if(v == null){
      parent.send(P_Trigger, null);
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
  maker0(Blocker){
    Blocker ret;
    IntRef active;
    OUT(P_Trigger);
    IN(TrigHandler, (active));
    IN(GateHandler, (active));
    return ret;
  }
}
