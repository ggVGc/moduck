public class Printer extends Moduck{
  "Printer" => string msg;

  fun void print(int v){
    <<< msg + "> " + v>>>;
  }

  fun int handle(string tag, int v){
    print(v);
    tag => out.tag;
    v => out.val;
    out.broadcast();
    return true;
  }

  fun static Printer make(string msg){
    Printer ret;
    msg => ret.msg;
    return ret;
  }
}

