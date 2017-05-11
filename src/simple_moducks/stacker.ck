
include(macros.m4)
include(constants.m4)


class Shared{
  IntRef signals[0];
  int stack[MAX_ROUTER_TARGETS];
  IntRef.make(-1) @=> IntRef curStackIndex;
}


class InHandler extends EventHandler{
  int handlerIndex;
  Shared shared;

  fun void handle(IntRef v){
    v @=> shared.signals[handlerIndex];
    if(v != null){
      if(shared.curStackIndex.i < 0){
        0 => shared.curStackIndex.i;
      }else{
        1 +=> shared.curStackIndex.i;
      }
      handlerIndex => shared.stack[shared.curStackIndex.i];
      parent.send(P_Trigger, v);
    }else{
      if(handlerIndex == shared.stack[shared.curStackIndex.i]){
        while(shared.curStackIndex.i >= 0){
          1 -=> shared.curStackIndex.i;
          if(shared.curStackIndex.i >= 0){
            shared.stack[shared.curStackIndex.i] => int sigInd;
            shared.signals[sigInd] @=> IntRef sig;
            if(sig != null){
              parent.send(P_Trigger, sig);
              break;
            }
          }
        }
      }
      if(shared.curStackIndex.i < 0){
        parent.send(P_Trigger, null);
      }
    }

    if(shared.curStackIndex.i >= 0){
      parent.send(P_Source, IntRef.make(shared.stack[shared.curStackIndex.i]));
    }
  }

  fun static InHandler make(int handlerIndex, Shared shared){
    InHandler ret;
    handlerIndex => ret.handlerIndex;
    shared @=> ret.shared;
    return ret;
  }
}


public class Stacker extends Moduck{
  maker0(Stacker){
    Stacker ret;
    Shared shared;
    OUT(P_Trigger);
    OUT(P_Source);
    for(0 => int i;i<MAX_ROUTER_TARGETS;++i){
      ret.addIn(""+i, InHandler.make(i, shared));
      shared.signals << null;
    }
    return ret;
  }
}
