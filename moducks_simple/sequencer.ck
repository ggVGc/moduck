
public class Sequencer extends Moduck{
  int entries[];
  int curStep;

  fun void init(int ents[], int loop){
    0 => curStep;
    ents @=> entries;
    setVal("loop", loop);
  }

  init([0], true);

  fun int handle(string tag, int v){
    if(tag == Pulse.Trigger()){
      entries[curStep] => out.val;
      out.broadcast();
      return true;
    }

    if(tag == Pulse.Reset()){
      0 => curStep;
      return true;
    }

    /* if(tag == "step"){ */
      step(v);
    /* } */
    return true;

  }

  fun void step(int ignored){
    entries[curStep] => out.val;
    if(curStep == entries.size() - 1){
      if(values["loop"].i){
        0 => curStep;
        "looped" => out.tag;
        out.broadcast();
      }
    }else{
      "stepped" => out.tag;
      curStep + 1 => curStep;
      out.broadcast();
    }

  }

  fun static Sequencer make(int entries[], int loop){
    Sequencer s;
    s.init(entries, loop);
    return s;
  }
}


