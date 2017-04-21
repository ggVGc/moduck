include(macros.m4)

class Shared{
  time lastTime;
}

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      parent.send(P_Trigger, IntRef.make(Util.toSamples(now - shared.lastTime)));
      now => shared.lastTime;
    }
  },
  Shared shared;
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      now => shared.lastTime;
      parent.send(P_Trigger, IntRef.make(1));
    }
  },
  Shared shared;
)

public class DeltaCounter extends Moduck{
  fun static DeltaCounter make(){
    DeltaCounter ret;
    Shared shared;
    OUT(P_Trigger);
    IN(TrigHandler, (shared));
    IN(ResetHandler, (shared));
    return ret;
  }
}
