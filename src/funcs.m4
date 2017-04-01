
class Eq extends IntRefFun{
  IntRef compareVal;
  fun IntRef call(IntRef v){
    if(compareVal == null && v == null){
      return IntRef.make(0);
    }else if(compareVal != null && v != null && compareVal.i == v.i){
      return IntRef.make(v.i);
    }else{
      return null;
    }
  }
  fun static Eq make(IntRef v){
    Eq ret;
    v @=> ret.compareVal;
    return ret;
  }

  fun static Eq make(int v){
    return make(IntRef.make(v));
  }
}


class NotEq extends IntRefFun{
  IntRef compareVal;
  fun IntRef call(IntRef v){
    if(compareVal == null && v != null){
      return IntRef.make(v.i);
    }else if(compareVal != null && v == null){
      return IntRef.make(compareVal.i);
    }else if(compareVal != null && v != null && v.i != compareVal.i){
      return IntRef.make(v.i);
    }else{
      return null;
    }
  }
  fun static NotEq make(IntRef v){
    NotEq ret;
    v @=> ret.compareVal;
    return ret;
  }

  fun static NotEq make(int v){
    return make(IntRef.make(v));
  }
}


class Not extends IntRefFun{
  IntRefFun f;
  fun IntRef call(IntRef v){
    f.call(v) @=> IntRef res;
    if(res == null){
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
