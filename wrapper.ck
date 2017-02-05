
public class Wrapper extends Moduck{
  Moduck @ src;

  fun int handle(string tag, int v){
    return src.handle(tag, v);
  }


  fun static Wrapper make(Moduck src, Moduck target){
    Wrapper ret;
    src @=> ret.src;
    target.out @=> ret.out;
    return ret;
  }
}
