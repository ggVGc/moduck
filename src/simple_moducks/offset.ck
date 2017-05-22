
include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger,
  IntRef tmpRef;
  HANDLE{
    if(null != v){
      v.i + parent.getVal("offset") => tmpRef.i;
      parent.send(P_Trigger, tmpRef);
    }else{
      parent.send(P_Trigger, null);
    }
  },
  int dummy;
)



public class Offset extends Moduck{

  fun static Offset make(int off){
    Offset ret;
    OUT(P_Trigger);
    IN(TrigHandler, (0));
    ret.addVal("offset", off);
    return ret;
  }
}

