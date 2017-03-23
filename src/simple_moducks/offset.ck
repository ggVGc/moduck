
include(macros.m4)

genHandler( TrigHandler, P_Trigger, HANDLE{
    if(null != v){
      parent.send(P_Trigger, IntRef.make(v.i + parent.getVal("offset")));
    }else{
      parent.send(P_Trigger, null);
    }
  },
;)



public class Offset extends Moduck{

  fun static Offset make(int off){
    Offset ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("offset", off);
    return ret;
  }
}

