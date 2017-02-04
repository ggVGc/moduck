
public class Value extends Handler{
  Util.iref(0) @=> values["value"];

  /* VEvent out; */
  
  fun int handle(string _, int __){
    values["value"].i => out.val;
    out.broadcast();
    return true;
  }
  fun static Value make(int v){
    Value ret;
    Util.iref(v) @=> ret.values["value"];
    return ret;
  }

  fun static Value False(){
    return Value.make(false);
  }
  fun static Value True(){
    return Value.make(true);
  }
}

