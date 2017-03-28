class AddFun extends IntFun{
  fun IntRef call(int v){
    return IntRef.make(v+parent.getVal("value"));
  };
}

public class Add{
  fun static ValProcessor make(int v){
    AddFun f;
    ValProcessor.make(f) @=> ValProcessor ret;
    ret.addVal("value", v);
    return ret;
  }
}
