
include(macros.m4)

fun int doMult(ModuckBase m, int count){
    1 => int acc;
    for(0 => int i; i<count; i++){
      acc * m.getVal(""+i) => acc;
    }
    return acc;
}

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      // TODO: Why is there a delay here?
      samp => now;
      parent.send(P_Trigger, IntRef.make(doMult(parent, inputCount)));
    }
  },
  int inputCount;
)



public class Multiplier extends Moduck{
  fun static Multiplier make(int inputCount){
    Multiplier ret;
    OUT(P_Trigger);
    TrigHandler.make(inputCount) @=> TrigHandler h;
    h.add(ret);
    for(0 => int i; i<inputCount; i++){
      ret.addVal(""+i, 1);
      Patch.connect(ret, recv(""+i), ret, P_Trigger);
    }
    return ret;
  }
}

