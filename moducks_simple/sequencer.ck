
public class Sequencer extends Moduck{
  int entries[];

  fun void init(int ents[], int loop){
    setVal("curStep", 0);
    ents @=> entries;
    setVal("loop", loop);
    setVal("targetStep", 0);
  }

  init([0], true);

  fun int handle(string tag, int v){
    if(tag == Pulse.Trigger()){
      send("seqOut", entries[getVal("curStep")]);
      return true;
    }

    if(tag == Pulse.Set()){
      v => entries[getVal("targetStep")];
      /* <<<"Seq setvalue">>>; */
      send("valueSet", getVal("targetStep"));
      return true;
    }

    if(tag == Pulse.Reset()){
      setVal("curStep", 0);
      return true;
    }

    /* if(tag == "step"){ */
      step(v);
    /* } */
    return true;

  }

  fun void step(int ignored){
    getVal("curStep") => int cur;

    entries[cur] => int v;
    if(cur == entries.size() - 1){
      if(values["loop"].i){
        setVal("curStep", 0);
      /* <<<"Seq looped">>>; */
        send("looped", v);
      }
    }else{
      send("stepped", v);
      /* <<<"Seq Stepped">>>; */
      setVal("curStep", cur + 1);
    }

  }

  fun static Sequencer make(int entries[], int loop){
    Sequencer s;
    s.init(entries, loop);
    return s;
  }
}


