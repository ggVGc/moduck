include(macros.m4)

genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      0 => accum.i;
    }
  },
  IntRef accum;
)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      parent.getVal("divisor") @=> int divisor;
      if(divisor > 0 && Math.remainder(accum.i, divisor) == 0){
        parent.send(P_Trigger, v);
      }
      accum.i + 1 => accum.i;
    }
  },
  IntRef accum;
)


public class PulseDiv extends Moduck{
  
  fun static PulseDiv make(int divisor, int startOffset){
    PulseDiv ret;

    OUT(P_Trigger);

    IntRef accum;
    IN(TrigHandler,(accum));
    IN(ResetHandler,(accum));

    ret.addVal("divisor", divisor);
    ret.addVal("offset", startOffset);

    ret.doHandle(P_Reset, IntRef.make(0));

    return ret;
  }


  fun static PulseDiv make(int divisor){
    return make(divisor, 0);
  }
}
