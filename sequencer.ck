
public class Sequencer extends Handler{
  int entries[];
  int curStep;

  fun void init(int ents[], int loop){
    0 => curStep;
    ents @=> entries;
    setVal("loop", loop);
  }

  init([0], true);


  /* VEvent out; */

  fun int handle(string type, int v){
    /* if(type == "step"){ */
      step(v);
      return true;
    /* } */
  }

  fun void step(int ignored){
    entries[curStep] => out.val;
    if(curStep == entries.size() - 1){
      if(values["loop"].i){
        0 => curStep;
        out.broadcast();
      }
    }else{
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


