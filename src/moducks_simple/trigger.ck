public class Trigger extends Moduck{
  string tag;
  fun void trigger(int v){
    send(tag, v);
  }

  fun static Trigger make(string tag){
    Trigger ret;
    ret.OUT(tag);
    tag => ret.tag;
    return ret;
  }
}

