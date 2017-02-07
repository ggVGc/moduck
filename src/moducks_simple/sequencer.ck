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


genHandler(SetHandler, Pulse.Set(),
  HANDLE{
    v => entries[parent.getVal("targetStep")];
    parent.send(Pulse.Set(), parent.getVal("targetStep"));
  },
  int entries[];
)

genHandler(Reset, Pulse.Reset(),
  HANDLE{
    parent.setVal("curStep", 0);
  },
  ;
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
    OUT(Pulse.Set());

    IN(TrigHandler, (entries, loop));
    IN(SetHandler, (entries));

    return ret;
  }
}

