
include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      V(srcMin)
      V(srcMax)
      V(outMin)
      V(outMax)
      if(v.i < srcMin || v.i > srcMax){
      return;
      }
      ((v.i-srcMin)$ float) / (srcMax-srcMin) @=> float d;
      parent.send(P_Trigger, IntRef.make(outMin + ((d * (outMax-outMin)) $ int)));
    }else{
      parent.send(P_Trigger, null);
    }
  },
)


public class RangeMapper extends Moduck{
  maker(RangeMapper, int srcMin, int srcMax, int outMin, int outMax){
    RangeMapper ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("srcMin", srcMin);
    ret.addVal("srcMax", srcMax);
    ret.addVal("outMin", outMin);
    ret.addVal("outMax", outMax);
    return ret;
  }
}

