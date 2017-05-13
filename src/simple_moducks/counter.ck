
include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger, 
  HANDLE{
    if(null != v){
      parent.setVal("count", parent.getVal("count")+1);
    }
    parent.send(P_Trigger, v);
  },
)

genHandler(ResetHandler, P_Reset, 
  HANDLE{
    if(null != v){
      parent.setVal("count", 0);
    }
  },
)


public class Counter extends Moduck{
  maker0(Counter){
    Counter ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    IN(ResetHandler, ());
    ret.addVal("count", 0);
    return ret;
  }
}
