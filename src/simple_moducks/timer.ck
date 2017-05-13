include(moduck_macros.m4)


genHandler(TrigHandler, P_Trigger,
  fun void doWait(int v){
    parent.getVal("ratio") @=> int ratio;
    parent.getVal("ratioMax") @=> int ratioMax;
    if(ratio <0 || ratio > ratioMax){
      <<<"Error(Attenuator): ratio larger than ratioMax">>>;
    }
    (ratio$float)/(parent.getVal("ratioMax")$float)=> float mul;
    Math.round(v*mul)$int @=> int trigVal;
    parent.send(P_Trigger, trigVal);
  }

  HANDLE{
    spork ~ doWait(v);
  },
;
)

public class Attenuator extends Moduck{
  maker(Attenuator, int initialRatio, int ratioMax){
    Attenuator ret;
    OUT(P_Trigger);
    IN(TrigHandler, ());
    ret.addVal("ratio", initialRatio);
    ret.addVal("ratioMax", ratioMax);
    return ret;
  }
}
