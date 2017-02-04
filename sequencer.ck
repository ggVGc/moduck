
public class Sequencer extends Handler{
  int entries[];
  0 => int curStep;
  Util.iref(true) @=> values["loop"];

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

  fun static Sequencer make(int entries[]){
    Sequencer s;
    entries @=> s.entries;
    return s;
  }
}


