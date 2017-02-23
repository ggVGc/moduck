public class Clamper extends Moduck{
  fun int handle(string tag, int v){
    getVal("min") => int min;
    getVal("max") => int max;
    if(v < min){
      min => v;
    }else if(v>max){
      max => v;
    }
    send(tag, v);
    return true;
  }

  fun static Clamper make(int min, int max){
    Clamper ret;
    ret.setVal("min", min);
    ret.setVal("max", max);
    return ret;
  }
}

