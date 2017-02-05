
public class Quant extends Moduck{
  fun int handle(string tag, int v){
    // TODO
    return false;
  }

  fun static Quant make(int min, int max){
    Quant ret;
    ret.setVal("min", min);
    ret.setVal("max", max);
    return ret;
  }
}

