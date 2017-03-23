
public class FloatRef{
  float f;

  fun static FloatRef make(float v){
    FloatRef ret;
    v => ret.f;
    return ret;
  }
}
