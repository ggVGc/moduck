include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger, 
  HANDLE{
    if(v != null){
      Runner.setBpm(v.i*Runner.ticksPerBeat);
    }
  },
  IntRef active;
)


public class BpmSetter extends Moduck{
  maker(BpmSetter, int offFromGate){
    BpmSetter ret;
    IntRef active;
    false => active.i;
    OUT(P_Trigger);
    IN(TrigHandler, (active));
    ret.addVal("offFromGate", offFromGate);
    return ret;
  }

}
