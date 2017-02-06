
public class Repeater extends Moduck{
  string relabel;
  fun int handle(string tag, int v){
    string newTag;
    if(relabel != null){
      relabel => newTag;
    }else{
      tag => newTag;
    }

    send(newTag, v);
    return true;
  }

  fun static Repeater make(){
    Repeater ret;
    return ret;
  }
  fun static Repeater withTag(string tag){
    Repeater.make() @=> Repeater ret;
    tag => ret.relabel;
    return ret;
  }
}
