public class Printer extends Moduck{
  "Printer" => string msg;

  fun void print(string tag, int v){
    /* <<<now>>>; */
    <<< msg + "> " + Util.strOrNull(tag)+":"+v>>>;
  }

  fun int handle(string tag, int v){
    print(tag, v);
    send(null, v);
    return true;
  }

  fun static Printer make(string msg){
    Printer ret;
    msg => ret.msg;
    return ret;
  }
}

