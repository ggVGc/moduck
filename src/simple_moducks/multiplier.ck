
include(macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    1 => int acc;
    samp => now;
    for(0 => int i; i<inputCount; i++){
      acc * parent.getVal(""+i) => acc;
    }
    parent.send(P_Trigger, acc);
  },
  int inputCount;
)


class SetHandler extends EventHandler{ 
  int ind;
  fun void handle(int v){
    parent.setVal(""+ind, v);
  }
  fun static SetHandler make(int ind){
    SetHandler ret;
    ind => ret.ind;
    return ret;
  }
}



public class Multiplier extends Moduck{
  fun static Multiplier make(int inputCount){
    Multiplier ret;
    OUT(P_Trigger);
    IN(TrigHandler, (inputCount));
    for(0 => int i; i<inputCount; i++){
      ret.addIn(""+i, SetHandler.make(i));
      ret.addVal(""+i, 1);
    }
    return ret;
  }
}

