include(macros.m4)

genHandler(TrigHandler, Pulse.Trigger(),
  fun void init(){
  }

  fun void step(){
    parent.getVal("curStep") => int cur;

    entries[cur] => int v;
    false => int looped;
    if(cur == entries.size() - 1){
      if(parent.getVal("loop")){
        parent.setVal("curStep", 0);
      /* <<<"Seq looped">>>; */
        true => looped;
      }
    }else{
      /* <<<"Seq Stepped">>>; */
      parent.setVal("curStep", cur + 1);
    }
    parent.send(Pulse.Stepped(), v);
    if(looped){
      parent.send(Pulse.Looped(), v);
    }
  }

  HANDLE{
    step();
    parent.send(Pulse.Trigger(), entries[parent.getVal("curStep")]);
  },
  int entries[];
  int loop;
)


public class Sequencer extends Moduck{
  fun static Sequencer make(int entries[], int loop){
    Sequencer ret;
    ret.setVal("curStep", 0);
    ret.setVal("loop", loop);
    ret.setVal("targetStep", 0);
    OUT(Pulse.Trigger());
    OUT(Pulse.Stepped());
    OUT(Pulse.Looped());

    IN(TrigHandler, (entries, loop));

    return ret;
  }
}




  /* fun int handle(string tag, int v){ */
  /*   if(tag == Pulse.Set()){ */
  /*     v => entries[getVal("targetStep")]; */
  /*     /* <<<"Seq setvalue">>>; */
  /*     send("valueSet", getVal("targetStep")); */
  /*     return true; */
  /*   } */
  /*  */
  /*   if(tag == Pulse.Reset()){ */
  /*     setVal("curStep", 0); */
  /*     return true; */
  /*   } */
  /*  */
  /*   /* if(tag == "step"){ */ 
  /*     step(v); */
  /*   /* } */
  /*   return true; */
  /*  */
  /* } */
