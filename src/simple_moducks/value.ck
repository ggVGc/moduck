include(macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      parent.send(P_Trigger, IntRef.make(parent.getVal("value")));
    }else{
      parent.send(P_Trigger, null);
    }
  },
  ;
)


public class Value extends Moduck{
  fun static Value make(int v){
    Value ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());

    ret.addVal("value", v);

    return ret;
  }

  fun static Value False(){
    return Value.make(false);
  }
  fun static Value True(){
    return Value.make(true);
  }
}

