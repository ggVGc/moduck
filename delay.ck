public class Delay extends Handler{
  /* VEvent out; */
  second => dur wait;
  Shred @ waiter;

  fun void doWait(int v){
    wait => now;
    v => out.val;
    out.broadcast();
  }

  fun int handle(string _, int v){
    if(waiter != null){
      waiter.exit();
      null @=> waiter;
    }
    spork ~ doWait(v) @=> waiter;
    return true;
  }

  fun static Delay make(dur wait){
    Delay d;
    wait => d.wait;
    return d;
  }
}

