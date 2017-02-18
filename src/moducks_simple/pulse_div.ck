include(macros.m4)

genHandler(ResetHandler, P_Reset,
  HANDLE{
    startOffset => shared.accum;
  },
  Shared shared;
  int startOffset;
)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(shared.accum == 0 || shared.accum >= parent.getVal("divisor")){
      parent.send(P_Trigger, v);
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

    OUT(P_Trigger);

    IN(TrigHandler,(ret.shared));
    IN(ResetHandler,(ret.shared, startOffset));

    ret.doHandle(P_Reset, 0);

    return ret;
  }
}
