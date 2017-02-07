include(macros.m4)

genHandler(ResetHandler, Pulse.Reset(),
  HANDLE{
    if(parent.getVal("triggerOnFirst")){
      0 => shared.accum;
    }else{
      1 => shared.accum;
    }
  },
  Shared shared;
)

genHandler(TrigHandler, Pulse.Trigger(),
  HANDLE{
    if(shared.accum == 0){
      parent.send(Pulse.Trigger(), v);
    }
    shared.accum + 1 => shared.accum;
    if(shared.accum >= parent.getVal("divisor")){
      0 => shared.accum;
    }
  },
  Shared shared;
)


class Shared{
  int accum;
}


public class PulseDiv extends Moduck{
  fun static PulseDiv make(int divisor, int triggerOnFirst){
    PulseDiv ret;
    Shared shared;
    ret.setVal("divisor", divisor);
    ret.setVal("triggerOnFirst", triggerOnFirst);

    OUT(Pulse.Trigger());

    IN(TrigHandler,(shared));
    IN(ResetHandler,(shared));

    ret.doHandle(Pulse.Reset(), 0);

    return ret;
  }
}
