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


public class TrigValue extends Moduck{
  fun static TrigValue make(int v){
    TrigValue ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());

    ret.addVal("value", v);

    return ret;
  }

  fun static TrigValue False(){
    return TrigValue.make(false);
  }
  fun static TrigValue True(){
    return TrigValue.make(true);
  }
}
