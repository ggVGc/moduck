class MulFun extends IntFun{
  fun IntRef call(int v){
    return IntRef.make(v*parent.getVal("value"));
  };
}

public class Mul{
  fun static ValProcessor make(int v){
    MulFun f;
    ValProcessor.make(f) @=> ValProcessor ret;
    ret.addVal("value", v);
    return ret;
  }
}
