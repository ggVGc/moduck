
include(macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.send(P_Trigger, v);
  }
  ;
)


public class Repeater extends Moduck{
  fun static Repeater make(){
    Repeater ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    return ret;
  }
}
