public class MayInt{
  0 => int i;
  false => int valid;

  fun void set(int v){
    true => valid;
    v => i;
  }

  fun void clear(){
    0 => int i;
    false => valid;
  }

  fun MayInt setFromRef(IntRef ref){
    if(ref == null){
      clear();
    }else{
      set(ref.i);
    }
  }

  fun static MayInt make(int v){
    MayInt ret;
    v => ret.i;
    return ret;
  }

  fun static MayInt make(){
    MayInt m;
    return m;
  }

  fun static MayInt fromRef(IntRef ref){
    return make().setFromRef(ref);
  }
}
