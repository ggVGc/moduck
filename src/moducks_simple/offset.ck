
include(macros.m4)

genHandler( TrigHandler, P_Trigger, HANDLE{
    parent.send(P_Trigger, v + parent.getVal("offset"));
  },
;)



public class Offset extends Moduck{

  fun static Offset make(int off){
    Offset ret;
    ret.setVal("offset", off);
    OUT(P_Trigger);
    IN(TrigHandler, ());
    return ret;
  }
}

