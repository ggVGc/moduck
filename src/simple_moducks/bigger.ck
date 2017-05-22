class BiggerFun extends IntFun{
  IntRef tmpVal;
  fun IntRef call(int v){
    if(v > parent.getVal("value")){
      v => tmpVal.i;
      return tmpVal;
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
