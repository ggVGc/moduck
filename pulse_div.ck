
public class PulseDiv extends Moduck{
  int accum;

  fun int handle(string tag, int v){
    if(tag == "reset"){
      0 => accum;
    }else{
      if(accum == 0){
        v => out.val;
        out.broadcast();
      }
      accum + 1 => accum;
      if(accum >= getVal("divisor")){
        0 => accum;
      }
    }
    return true;
  }
  
  fun static PulseDiv make(int divisor){
    PulseDiv ret;
    ret.handle("reset", 0);
    Util.setVal(ret, "divisor", divisor);
    return ret;
  }
}
