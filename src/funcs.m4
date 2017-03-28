
class Eq extends IntRefFun{
  IntRef compareVal;
  fun IntRef call(IntRef v){
    if(compareVal == null && v == null){
      return IntRef.make(0);
    }else if(compareVal == null || v == null){
      return null;
    }else if(compareVal.i == v.i){
      return IntRef.make(0);
    }else{
      return null;
    }
  }
  fun static Eq make(IntRef v){
    Eq ret;
    v @=> ret.compareVal;
    return ret;
  }
}

class Not extends IntRefFun{
  IntRefFun f;
  fun IntRef call(IntRef v){
    f.call(v) @=> IntRef res;
    if(v == null){
      return IntRef.make(0);
    }else{
      return null;
    }
  }

  fun static Not make(IntRefFun f){
    Not ret;
    f @=> ret.f;
    return ret;
  }
}
