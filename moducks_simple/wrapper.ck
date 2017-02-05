
public class Wrapper extends Moduck{
  Moduck @ src;

  fun int handle(string tag, int v){
    return src.handle(tag, v);
  }


  fun static Wrapper make(Moduck src, SrcEvent outEv){
    Wrapper ret;
    src @=> ret.src;
    outEv @=> ret.out;
    return ret;
  }
}
