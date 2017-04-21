class DivFun extends IntFun{
  fun IntRef call(int v){
    return IntRef.make(Math.floor((v $ float) / (parent.getVal("value") $ float)) $ int);
  };
}

public class Div{
  fun static ValProcessor make(int v){
    DivFun f;
    ValProcessor.make(f) @=> ValProcessor ret;
    ret.addVal("value", v);
    return ret;
  }
}
