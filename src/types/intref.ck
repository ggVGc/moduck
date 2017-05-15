
public class IntRef{
  0 => int i;

  fun static IntRef make(int v){
    IntRef i;
    v => i.i;
    return i;
  }

  fun static IntRef yes(){
    return make(1);
  }
}
