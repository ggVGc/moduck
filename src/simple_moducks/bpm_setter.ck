include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger, 
  HANDLE{
    if(v != null){
      Runner.setBpm(v.i*Runner.ticksPerBeat);
    }
  },
  ;
)


public class BpmSetter extends Moduck{
  maker0(BpmSetter){
    BpmSetter ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    return ret;
  }

}
