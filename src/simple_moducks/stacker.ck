
include(moduck_macros.m4)
include(constants.m4)


class Shared{
  MayInt signals[MAX_ROUTER_TARGETS];
  int stack[MAX_ROUTER_TARGETS];
  IntRef.make(-1) @=> IntRef curStackIndex;
}


class InHandler extends EventHandler{
  int handlerIndex;
  Shared shared;

  IntRef tmpRef;

  IntRef.make(0) @=> IntRef tmpOutRef;

  fun void handle(IntRef v){
    shared.signals[handlerIndex].setFromRef(v);
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
            shared.signals[sigInd] @=> MayInt sig;
            if(sig.valid){
              sig.i => tmpRef.i;
              parent.send(P_Trigger, tmpRef);
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
      shared.stack[shared.curStackIndex.i] => tmpOutRef.i;
      parent.send(P_Source, IntRef.make(tmpOutRef.i));
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
    }
    return ret;
  }
}
