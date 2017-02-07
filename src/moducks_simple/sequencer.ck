include(macros.m4)

genHandler(TrigHandler, Pulse.Trigger(),
  fun void init(){
    parent.setVal("curStep", 0);
    parent.setVal("loop", loop);
    parent.setVal("targetStep", 0);
  }

  fun void step(int ignored){
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
    parent.send(Pulse.Trigger(), entries[parent.getVal("curStep")]);
  },
  int entries[];
  int loop;
)


public class Sequencer extends Moduck{




  fun static Sequencer make(int entries[], int loop){
    Sequencer ret;
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
