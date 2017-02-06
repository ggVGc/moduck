

public class ModuckBase{
  IntRef values[0]; // Completely arbitrary sizes
  VEvent outs[0];
  string outKeys[0];

  
  fun void addOut(string tag){
    outKeys << tag;
    VEvent ev;
    ev @=> outs[tag];
  }

  fun void send(string tag, int v){
    v => outs[tag].val;
    outs[tag].broadcast();
  }

  fun int getVal(string key){
    return values[key].i;
  }

  fun void setVal(string key, int v){
    IntRef.make(v) @=> values[key];
  }

  fun void setValRef(string key, IntRef v){
    v @=> values[key];
  }
}




