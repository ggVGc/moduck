public class Delay extends Moduck{
  Shred @ waiter;

  fun void doWait(string tag, int v){
    values["delay"].i :: samp => now;
    /* <<< now >>>; */
    send(tag, v);
  }

  fun int handle(string tag, int v){
    if(waiter != null){
      waiter.exit();
      null @=> waiter;
    }
    spork ~ doWait(tag, v) @=> waiter;
    return true;
  }

  fun static Delay make(dur delay){
    Delay d;
    d.setVal("delay", Util.toSamples(delay));
    return d;
  }
}



/* 
 public class Delay extends Moduck{
   null => Shred @ waiter;
 
   false => int waited;
   fun void doWait(string tag, int v){
     values["delay"].i :: samp => now;
     true => waited;
   }
 
   fun int handle(string tag, int v){
     if(waiter == null){
       spork ~ doWait(tag, v) @=> waiter;
     }else{
       if(waited){
         send(tag, v);
       }
     }
     return true;
   }
 
   fun static Delay make(dur delay){
     Delay d;
     d.setVal("delay", Util.toSamples(delay));
     return d;
   }
 }
 */
