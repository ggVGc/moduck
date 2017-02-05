
public class IntRef{
  int i;

  fun static IntRef make(int v){
    IntRef i;
    v => i.i;
    return i;
  }
}
