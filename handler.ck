
public class Handler{
  IntRef values[10]; // Completely arbitrary
  fun int handle(string msg, int v){};

  fun int getVal(string key){
    return values[key].i;
  }

  SrcEvent out;

}
