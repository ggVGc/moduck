include(macros.m4)

genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      parent.getVal("offset") => accum.f;
      0 => highest.i;
      0 => lastScaling.f;
    }
  },
  FloatRef accum;
  IntRef highest;
  FloatRef lastScaling;
)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      parent.getVal("scaling") / 100.0 => float scaling;
      if(scaling > 0){
        if(!Util.equals(lastScaling.f, scaling)){
          scaling => lastScaling.f;
          0 => highest.i;
        }
        V(divisor)
        /* 
         if(divisor <0){
           WARNING("Divisor is negative! "+divisor);
         }
         */
        Math.floor(accum.f * scaling) => float adjustedAccum;
        if(divisor > 0){
          Math.ceil(adjustedAccum / divisor ) $ int => int loopIndex;
          if(loopIndex > highest.i){
            parent.sendPulse(P_Trigger, v.i);
            loopIndex => highest.i;
          }
        }
      }
      accum.f + 1 => accum.f;
    }
  },
  FloatRef accum;
  IntRef highest;
  FloatRef lastScaling;
)


public class PulseDiv extends Moduck{
  
  fun static PulseDiv make(int divisor){
    PulseDiv ret;

    OUT(P_Trigger);

    FloatRef accum;
    IntRef highest;
    FloatRef lastScaling;
    IN(TrigHandler,(accum, highest, lastScaling));
    IN(ResetHandler,(accum, highest, lastScaling));

    ret.addVal("divisor", divisor);
    ret.addVal("offset", 0);
    ret.addVal("scaling", 100); // percentage

    ret.doHandle(P_Reset, IntRef.make(0));

    return ret;
  }

}
