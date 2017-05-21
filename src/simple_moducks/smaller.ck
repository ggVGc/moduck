class SmallerFun extends IntFun{
  fun IntRef call(int v){
    if(v < parent.getVal("value")){
      return IntRef.make(v);
    }else{
      return null;
    }
  };
}

public class Smaller{
  fun static ValProcessor make(int v){
    SmallerFun f;
    ValProcessor.make(f) @=> ValProcessor ret;
    ret.addVal("value", v);
    return ret;
  }
}
