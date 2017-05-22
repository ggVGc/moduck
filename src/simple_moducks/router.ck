include(moduck_macros.m4)

include(constants.m4)

class Shared{
  MayInt lastVal;
}


genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.send("" + parent.getVal("index"), v);
    if(v == null){
      shared.lastVal.clear();
    }else{
      shared.lastVal.set(v.i);
    }
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
  IntRef tmpRef;

  fun void onValueChange(string tag, int old, int newVal){
    if(shared.lastVal.valid){
      send(""+old, null);
      if(getVal("outOnChange")){
        shared.lastVal.i => tmpRef.i;
        send(""+newVal, tmpRef);
      }
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

    // If Gate is high and index is changed,
    // output the last trigger value on the new indexed port
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
