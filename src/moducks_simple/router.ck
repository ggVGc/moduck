include(macros.m4)

include(constants.m4)

genHandler(TrigHandler, Pulse.Trigger(),
  HANDLE{
    parent.send("" + parent.getVal("index"), v);
  }
  ;
)


public class Router extends Moduck{
  fun static Router make(int startIndex){
    Router ret;
    for(0 => int i;i<MAX_ROUTER_TARGETS;++i){
      ret.addOut(""+i);
    }
    IN(TrigHandler, ());
    ret.setVal("index", startIndex);
    return ret;
  }
}
