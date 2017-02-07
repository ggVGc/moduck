include(macros.m4)

genHandler(TrigHandler, Pulse.Trigger(),
  HANDLE{
    parent.send(Pulse.Trigger(), parent.getVal("value"));
  },
  ;
)


public class Value extends Moduck{
  fun static Value make(int v){
    Value ret;
    OUT(Pulse.Trigger());
    ret.setVal("value", v);
    IN(TrigHandler, ());
    return ret;
  }

  fun static Value False(){
    return Value.make(false);
  }
  fun static Value True(){
    return Value.make(true);
  }
}

