public class Delay extends Moduck{
  Shred @ waiter;

  fun void setWait(dur d){
    Util.toSamples(d) @=> values["wait"];
  }
  setWait(second);

  fun void doWait(int v){
    values["wait"].i :: samp => now;
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
    d.setWait(wait);
    return d;
  }
}

