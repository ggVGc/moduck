
include(pulses.m4)

public class Wrapper extends Moduck{
  fun static Wrapper make(Moduck src, Moduck target){
    Wrapper ret;
    src.handlerKeys @=> ret.handlerKeys;
    src.handlers @=> ret.handlers;
    src.values @=> ret.values;

    // Copy all non-recv outs
    for(0 => int i; i<target.outKeys.size(); i++){
      target.outKeys[i] @=> string k;
      if(!isRecvPulse(k) && !target.hasValueKey(k)){
        target.outs[k] @=> ret.outs[k];
        ret.outKeys << k;
      }
    }

    // Add recv out handlers from src to target
    for(0 => int i; i<src.outKeys.size(); i++){
      src.outKeys[i] => string k;
      if(isRecvPulse(k)){
        src.outs[k] @=> ret.outs[k];
        ret.outKeys << k;
      }
    }

    return ret;
  }
}
