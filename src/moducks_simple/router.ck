include(macros.m4)

include(constants.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.send("" + parent.getVal("index"), v);
  }
  ;
)

genHandler(ResetHandler, P_Reset,
 HANDLE{
  parent.setVal("index", startIndex);
 },
 int startIndex;
)


public class Router extends Moduck{
  fun static Router make(int startIndex){
    Router ret;
    for(0 => int i;i<MAX_ROUTER_TARGETS;++i){
      ret.addOut(""+i);
    }
    IN(TrigHandler, ());
    IN(ResetHandler, (startIndex));
    ret.setVal("index", startIndex);
    return ret;
  }
}
