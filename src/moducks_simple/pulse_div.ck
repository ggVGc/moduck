include(macros.m4)

genHandler(ResetHandler, Pulse.Reset(),
  HANDLE{
    parent.getVal("startOffset") => shared.accum;
  },
  Shared shared;
)

genHandler(TrigHandler, Pulse.Trigger(),
  HANDLE{
    if(shared.accum == 0 || shared.accum >= parent.getVal("divisor")){
      parent.send(Pulse.Trigger(), v);
      0 => shared.accum;
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
  Shared shared;
  /*
    fun void onValChange(string key, int v){
      <<< "DivChange", v>>>;
      if(key == "divisor" && shared.accum >= getVal("divisor")){
        0 => shared.accum;
      }
    }
   */
  
  fun static PulseDiv make(int divisor, int startOffset){
    PulseDiv ret;
    ret.setVal("divisor", divisor);
    ret.setVal("startOffset", startOffset);

    OUT(Pulse.Trigger());

    IN(TrigHandler,(ret.shared));
    IN(ResetHandler,(ret.shared));

    ret.doHandle(Pulse.Reset(), 0);

    return ret;
  }
}
