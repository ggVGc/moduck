
include(moduck_macros.m4)
include(constants.m4)


class InHandler extends EventHandler{
  int handlerIndex;
  MayInt signals[];

  IntRef tmpRef;

  fun void handle(IntRef v){
    -1 => int highestInd;
    -1 => int secondHighestInd;
    int secondHighestVal;
    for(signals.size()-1=>int sigInd;sigInd>=0;--sigInd){
      signals[sigInd] @=> MayInt sig;
      if(sig.valid){
        if(highestInd == -1){
          sigInd => highestInd;
        }else{
          sigInd => secondHighestInd;
          sig.i => secondHighestVal;
          break;
        }
      }
    }

    if(v == null){
      if(handlerIndex == highestInd){
        if(secondHighestInd != -1){
          secondHighestVal => tmpRef.i;
          parent.send(P_Trigger, tmpRef);
        }else{
          parent.send(P_Trigger, null);
        }
      }
      signals[handlerIndex].clear();
    }else{
      if(handlerIndex >= highestInd){
        parent.send(P_Trigger, v);
      }
      signals[handlerIndex].set(v.i);
    }
  }

  fun static InHandler make(int handlerIndex, MayInt signals[]){
    InHandler ret;
    handlerIndex => ret.handlerIndex;
    signals @=> ret.signals;
    return ret;
  }
}

public class Prio extends Moduck{
  maker0(Prio){
    Prio ret;
    MayInt signals[MAX_ROUTER_TARGETS];
    OUT(P_Trigger);
    for(0 => int i;i<MAX_ROUTER_TARGETS;++i){
      ret.addIn(""+i, InHandler.make(i, signals));
    }
    return ret;
  }
}
