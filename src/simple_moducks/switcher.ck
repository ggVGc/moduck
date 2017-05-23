include(moduck_macros.m4)

include(constants.m4)




genTagHandler(InputTagHandler,
    HANDLE{
      lastVals[tag].setFromRef(v);

      if(parent.getVal("onlyOutOnNewIndex")){
        return;
      }

      V(index);

      if(tag == ""+index){
        parent.send(P_Trigger, v);
      }
    },
  MayInt lastVals[];
)



genHandler(ResetHandler, P_Reset,
 HANDLE{
  parent.setVal("index", startIndex);
 },
 int startIndex;
)


public class Switcher extends Moduck{

  MayInt  lastVals[0];

  IntRef tmpRef;

  fun void onValueChange(string tag, int old, int newVal){
    if(tag == "index"){
      lastVals[""+newVal].i => tmpRef.i;
      send(P_Trigger, tmpRef);
    }
  }


  fun static Switcher make(int count, int startIndex, int onlyOutOnNewIndex){
    Switcher ret;
    OUT(P_Trigger);
    for(0 => int i;i<count;++i){
      IN(InputTagHandler, (""+i, ret.lastVals));
      MayInt.make() @=> ret.lastVals[""+i];
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
