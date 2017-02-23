
include(macros.m4)

genHandler( TrigHandler, P_Trigger, HANDLE{
    parent.send(P_Trigger, v + parent.getVal("offset"));
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

