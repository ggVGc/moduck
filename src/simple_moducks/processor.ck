include(macros.m4)



genHandler(TrigHandler, P_Trigger,
  HANDLE{
    f.call(v) @=> IntRef ret;
    if(ret != null){
      parent.send(P_Trigger, ret);
    }else if(parent.getVal("nullOnFalse")){
      parent.send(P_Trigger, null);
    }
  },
  IntRefFun f;
)

public class Processor extends Moduck{
  fun static Processor make(IntRefFun f, int nullOnFalse){
    Processor ret;
    ret @=> f.parent;
    OUT(P_Trigger);
    IN(TrigHandler, (f));
    ret.addVal("nullOnFalse", nullOnFalse);
    return ret;
  }

  fun static Processor make(IntRefFun f){
    return make(f, true);
  }
}

