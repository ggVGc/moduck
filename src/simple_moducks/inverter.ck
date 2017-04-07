include(macros.m4)
include(song_macros.m4)


genHandler(TrigHandler, P_Trigger, 
  HANDLE{
    if(v == null){
      parent.send(P_Trigger, IntRef.make(parent.getVal("value")));
    }else{
      parent.send(P_Trigger, null);
    }
  },
  ;
)

public class Inverter extends Moduck{
  maker(Inverter, int v){
    Inverter ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("value", v);
    return ret;
  }

  fun static Inverter make(){
    return make(0);
  }
}
