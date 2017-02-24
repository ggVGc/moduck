
include(macros.m4)


fun void print(string msg, int v){
    <<< msg + ">" + ":" + v + " - ", Math.floor(now/samp) $ int >>>;
}


genHandler(TrigHandler, P_Trigger,
  fun void handle(int v){
    print(msg, v);
    parent.send(P_Trigger, v);
  },
  string msg;
)



public class Printer extends Moduck{
  fun static Printer make(string msg){
    Printer ret;
    OUT(P_Trigger);
    IN(TrigHandler, (msg));
    return ret;
  }
}
