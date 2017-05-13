include(moduck_macros.m4)


genHandler(GateHandler, P_Gate,
  HANDLE{
    if(null != v){
      parent.getVal("ratio") @=> int ratio;
      parent.getVal("ratioMax") @=> int ratioMax;
      if(ratio <0 || ratio > ratioMax){
        <<<"Error(Attenuator): ratio larger than ratioMax">>>;
      }
      (ratio$float)/(parent.getVal("ratioMax") $ float)=> float mul;
      Math.round(v.i * mul) $ int @=> int trigVal;
      parent.send(P_Trigger, IntRef.make(trigVal));
    }else{
      parent.send(P_Trigger, null);
    }
  },
;
)

public class Attenuator extends Moduck{
  maker(Attenuator, int initialRatio, int ratioMax){
    Attenuator ret;
    OUT(P_Trigger);
    IN(GateHandler, ());
    ret.addVal("ratio", initialRatio);
    ret.addVal("ratioMax", ratioMax);
    return ret;
  }
}
