


class Print extends EventHandler{
  string msg;

  fun void handle(int v){
    <<< msg + "> " +":"+v>>>;
  }

  fun static Print make(string msg){
    Print ret;
    msg => ret.msg;
    return ret;
  }
}




public class Printer extends Moduck{
  "Printer" => string msg;

  fun static Printer make(string msg){
    Printer ret;
    ret.handler(Pulse.Trigger(), Print.make(msg));
    return ret;
  }
}

