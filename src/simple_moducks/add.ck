class AddFun extends IntFun{
  fun IntRef call(int v){
    return IntRef.make(v+parent.getVal("value"));
  };
}

public class Add{
  fun static Processor make(int v){
    AddFun f;
    Processor.make(f) @=> Processor ret;
    ret.addVal("value", v);
    return ret;
  }
}
