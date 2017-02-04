
public class PulseDiv extends Moduck{
  int accum;

  fun int handle(string tag, int v){
    if(tag == "reset"){
      0 => accum;
    }else{
      if(accum == getVal("divisor")){
        v => out.val;
        out.broadcast();
        0 => accum;
      }else{
        accum + 1 => accum;
      }
    }
    return true;
  }
  
  fun static PulseDiv make(int diviso){
    PulseDiv ret;
    ret.handle("reset", 0);
    Util.setVal(ret, "divisor", diviso);
    return ret;
  }
}
