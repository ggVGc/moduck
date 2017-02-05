
public class PulseDiv extends Moduck{
  int accum;

  fun int handle(string tag, int v){
    if(tag == Pulse.Reset()){
      if(getVal("triggerOnFirst")){
        0 => accum;
      }else{
        1 => accum;
      }
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
  
  fun static PulseDiv make(int divisor, int triggerOnFirst){
    PulseDiv ret;
    ret.setVal("triggerOnFirst", triggerOnFirst);
    ret.handle(Pulse.Reset(), 0);
    ret.setVal("divisor", divisor);
    return ret;
  }
}
