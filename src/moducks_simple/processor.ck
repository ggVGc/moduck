include(macros.m4)



genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.send(P_Trigger, f.call(v));
  },
  IntFun f;
)

public class Processor extends Moduck{
  fun static Processor make(IntFun f){
    Processor ret;
    OUT(P_Trigger);
    IN(TrigHandler, (f))
    return ret;
  }
}

