
public class Value extends Handler{
  IntRef.make(0) @=> values["value"];

  /* VEvent out; */
  
  fun int handle(string _, int __){
    values["value"].i => out.val;
    out.broadcast();
    return true;
  }
  fun static Value make(int v){
    Value ret;
    IntRef.make(v) @=> ret.values["value"];
    return ret;
  }

  fun static Value False(){
    return Value.make(false);
  }
  fun static Value True(){
    return Value.make(true);
  }
}

