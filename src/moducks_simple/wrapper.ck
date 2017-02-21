
include(pulses.m4)

public class Wrapper extends Moduck{
  fun static Wrapper make(Moduck src, Moduck target){
    Wrapper ret;
    src.handlerKeys @=> ret.handlerKeys;
    src._handlers @=> ret._handlers;


    // Copy all non-recv outs
    for(0 => int i; i<target._outKeys.size(); i++){
      target._outKeys[i] @=> string k;
      if(!isRecvPulse(k)){
        target._outs[k] @=> ret._outs[k];
        ret._outKeys << k;
      }
    }

    // Add recv out handlers from src to target
    for(0 => int i; i<src._outKeys.size(); i++){
      src._outKeys[i] => string k;
      if(isRecvPulse(k)){
        src._outs[k] @=> ret._outs[k];
        ret._outKeys << k;
      }
    }

    return ret;
  }
}
