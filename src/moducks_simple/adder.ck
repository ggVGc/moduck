
include(macros.m4)

genHandler(TrigHandler, Pulse.Trigger(),
  HANDLE{
    0 => int acc;
    for(0 => int i; i<inputCount; i++){
      acc + parent.getVal(""+i) => acc;
    }
    parent.send(Pulse.Trigger(), acc);
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



public class Adder extends Moduck{
  fun static Adder make(int inputCount){
    Adder ret;
    OUT(Pulse.Trigger());
    IN(TrigHandler, (inputCount))
    for(0 => int i; i<inputCount; i++){
      ret.addIn(""+i, SetHandler.make(i));
      ret.setVal(""+i, 1);
    }
    return ret;
  }
}

