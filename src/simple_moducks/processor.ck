include(macros.m4)



genHandler(TrigHandler, P_Trigger,
  HANDLE{
    f.call(v) @=> IntRef ret;
    if(ret != null){
      parent.send(P_Trigger, ret.i);
    }
  },
  IntFun f;
)

public class Processor extends Moduck{
  fun static Processor make(IntFun f){
    Processor ret;
    ret @=> f.parent;
    OUT(P_Trigger);
    IN(TrigHandler, (f));
    return ret;
  }
}

