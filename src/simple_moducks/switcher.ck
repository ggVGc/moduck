include(moduck_macros.m4)

include(constants.m4)




genTagHandler(InputTagHandler,
    HANDLE{
      V(index);

      <<<"Recv: "+index>>>;
      if(tag == ""+index){
        parent.send(P_Trigger, v);
      }
      v @=> lastVals[tag];
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


  fun static Switcher make(int count, int startIndex, int outOnChange){
    Switcher ret;
    OUT(P_Trigger);
    for(0 => int i;i<count;++i){
      IN(InputTagHandler, (""+i, ret.lastVals));
      null @=> ret.lastVals[""+i];
    }
    IN(ResetHandler, (startIndex));
    ret.addVal("index", startIndex);

    ret.addVal("outOnChange", outOnChange);
     // If Gate is high and index is changed,
     // output the last trigger value on the new indexed port

    return ret;
  }


  fun static Switcher make(int count, int startIndex){
    return make(count, startIndex, true);
  }


  fun static Switcher make(int count){
    return make(count, 0);
  }
}
