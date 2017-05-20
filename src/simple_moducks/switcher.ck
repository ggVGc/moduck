include(moduck_macros.m4)

include(constants.m4)




genTagHandler(InputTagHandler,
    HANDLE{
      v @=> lastVals[tag];

      if(parent.getVal("onlyOutOnNewIndex")){
        return;
      }

      V(index);

      if(tag == ""+index){
        parent.send(P_Trigger, v);
      }
    },
  IntRef lastVals[];
)



genHandler(ResetHandler, P_Reset,
 HANDLE{
  parent.setVal("index", startIndex);
 },
 int startIndex;
)


public class Switcher extends Moduck{

  IntRef lastVals[0];

  fun void onValueChange(string tag, int old, int newVal){
    if(tag == "index"){
      send(P_Trigger, lastVals[""+newVal]);
    }
  }


  fun static Switcher make(int count, int startIndex, int onlyOutOnNewIndex){
    Switcher ret;
    OUT(P_Trigger);
    for(0 => int i;i<count;++i){
      IN(InputTagHandler, (""+i, ret.lastVals));
      null @=> ret.lastVals[""+i];
    }
    IN(ResetHandler, (startIndex));
    ret.addVal("index", startIndex);
    ret.addVal("onlyOutOnNewIndex", onlyOutOnNewIndex);

    return ret;
  }


  fun static Switcher make(int count, int startIndex){
    return make(count, startIndex, false);
  }

  fun static Switcher make(int count){
    return make(count, 0);
  }
}
