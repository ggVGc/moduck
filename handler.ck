
public class Handler{
  IntRef values[10]; // Completely arbitrary
  fun int handle(string msg, int v){};

  fun int getVal(string key){
    return values[key].i;
  }


  fun void setVal(string key, int v){
    IntRef.make(v) @=> values[key];
  }


  fun void setValRef(string key, IntRef v){
    v @=> values[key];
  }

  SrcEvent out;

}
