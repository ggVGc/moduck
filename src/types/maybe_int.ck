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

  fun static MayInt make(int v){
    MayInt ret;
    v => ret.i;
    return ret;
  }
}
