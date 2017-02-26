include(macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.send("value", parent.getVal("value"));
  },
  ;
)


public class Value extends Moduck{
  fun static Value make(int v){
    Value ret;
    IN(TrigHandler, ());

    ret.addVal("value", v);

    return ret;
  }

  fun static Value False(){
    return Value.make(false);
  }
  fun static Value True(){
    return Value.make(true);
  }
}

