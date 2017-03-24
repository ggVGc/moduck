class MulFun extends IntFun{
  fun IntRef call(int v){
    return IntRef.make(v*parent.getVal("value"));
  };
}

public class Mul{
  fun static Processor make(int v){
    MulFun f;
    Processor.make(f) @=> Processor ret;
    ret.addVal("value", v);
    return ret;
  }
}
