
include(macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    V(srcMin)
    V(srcMax)
    V(outMin)
    V(outMax)
    if(v < srcMin || v > srcMax){
      return;
    }
    ((v-srcMin)$ float) / (srcMax-srcMin) @=> float d;
    <<< d >>>;
    parent.send(P_Trigger, outMin + ((d * (outMax-outMin)) $ int));
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

