public class Delay extends Moduck{
  Shred @ waiter;

  fun void doWait(string tag, int v){
    values["delay"].i :: samp => now;
    v => out.val;
    tag => out.tag;
    out.broadcast();
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

