
include(macros.m4)


fun void print(string msg, IntRef v){
  string valStr;
  if(null != v){
    ""+v.i @=> valStr;
  }else{
    "nil" @=> valStr;
  }
  <<< Math.floor(now/samp) $ int , " - "+ msg + ": " + valStr >>>;
}


genHandler(TrigHandler, P_Trigger,
  fun void handle(IntRef v){
    if(Printer.enabled){
      print(msg, v);
    }
    parent.send(P_Trigger, v);
  },
  string msg;
)



public class Printer extends Moduck{
  static int enabled;
  fun static Printer make(string msg){
    Printer ret;
    OUT(P_Trigger);
    IN(TrigHandler, (msg));
    return ret;
  }
}

true => Printer.enabled;
