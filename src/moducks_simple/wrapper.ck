
public class Wrapper extends Moduck{
  fun static Wrapper make(Moduck src, Moduck target){
    Wrapper ret;
    src.handlerKeys @=> ret.handlerKeys;
    src.handlers @=> ret.handlers;
    target.outs @=> ret.outs;
    return ret;
  }
}
