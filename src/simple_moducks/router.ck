include(macros.m4)

include(constants.m4)

class Shared{
  null @=> IntRef lastVal;
}


genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.send("" + parent.getVal("index"), v);
    v @=> shared.lastVal;
  },
  Shared shared;
)

genHandler(ResetHandler, P_Reset,
 HANDLE{
  parent.setVal("index", startIndex);
 },
 int startIndex;
)


public class Router extends Moduck{
  Shared shared;
  fun void onValueChange(string tag, int old, int newVal){
    send(""+old, null);
    if(shared.lastVal != null && getVal("outOnChange")){
      send(""+newVal, shared.lastVal);
    }
  }

  fun static Router make(int startIndex, int outOnChange){
    Router ret;
    for(0 => int i;i<MAX_ROUTER_TARGETS;++i){
      ret.addOut(""+i);
    }
    IN(TrigHandler, (ret.shared));
    IN(ResetHandler, (startIndex));

    ret.addVal("index", startIndex);
    ret.addVal("outOnChange", outOnChange);
    return ret;
  }


  fun static Router make(int startInd){
    return make(startInd, true);
  }

  fun static Router make(){
    return make(0);
  }
}
