
include(moduck_macros.m4)
include(constants.m4)


class InHandler extends EventHandler{
  int handlerIndex;
  IntRef signals[];

  fun void handle(IntRef v){
    -1 => int highestInd;
    -1 => int secondHighestInd;
    IntRef highestVal;
    IntRef secondHighestVal;
    for(signals.size()-1=>int sigInd;sigInd>=0;--sigInd){
      signals[sigInd] @=> IntRef sig;
      if(sig != null){
        if(highestInd == -1){
          sigInd => highestInd;
          sig @=> highestVal;
        }else{
          sigInd => secondHighestInd;
          sig @=> secondHighestVal;
          break;
        }
      }
    }

    if(v == null){
      if(handlerIndex == highestInd){
        if(secondHighestInd != -1){
          parent.send(P_Trigger, secondHighestVal);
        }else{
          parent.send(P_Trigger, null);
        }
      }
      null @=> signals[handlerIndex];
    }else{
      if(handlerIndex >= highestInd){
        parent.send(P_Trigger, v);
      }
      v @=> signals[handlerIndex];
    }
  }

  fun static InHandler make(int handlerIndex, IntRef signals[]){
    InHandler ret;
    handlerIndex => ret.handlerIndex;
    signals @=> ret.signals;
    return ret;
  }
}

public class Prio extends Moduck{
  maker0(Prio){
    Prio ret;
    IntRef signals[0];
    OUT(P_Trigger);
    for(0 => int i;i<MAX_ROUTER_TARGETS;++i){
      ret.addIn(""+i, InHandler.make(i, signals));
      signals << null;
    }
    return ret;
  }
}
