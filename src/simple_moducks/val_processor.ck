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

public class ValProcessor extends Moduck{
  fun static ValProcessor make(IntFun f){
    ValProcessor ret;
    ret @=> f.parent;
    OUT(P_Trigger);
    IN(TrigHandler, (f));
    return ret;
  }
}

