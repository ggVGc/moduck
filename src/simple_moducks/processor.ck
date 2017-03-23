include(macros.m4)



genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      f.call(v.i) @=> IntRef ret;
      if(ret != null){
        parent.send(P_Trigger, ret);
      }
    }else{
      parent.send(P_Trigger, null);
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

