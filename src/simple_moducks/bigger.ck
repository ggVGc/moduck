class BiggerFun extends IntFun{
  fun IntRef call(int v){
    if(v > parent.getVal("value")){
      return IntRef.make(v);
    }else{
      return null;
    }
  };
}

public class Bigger{
  fun static ValProcessor make(int v){
    BiggerFun f;
    ValProcessor.make(f) @=> ValProcessor ret;
    ret.addVal("value", v);
    return ret;
  }
}
