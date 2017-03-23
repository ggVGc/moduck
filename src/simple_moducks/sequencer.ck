include(macros.m4)


fun void doStep(ModuckBase parent, int entries[], int loop){
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
  parent.sendPulse(P_Stepped, v);
  if(looped){
    parent.sendPulse(P_Looped, v);
  }
}

genHandler(StepTrigHandler, P_StepTrigger,
  fun void init(){}

  HANDLE{
    parent.sendPulse(P_Trigger, entries[parent.getVal("curStep")]);
    doStep(parent, entries, loop);
  },
  int entries[];
  int loop;
)


genHandler(StepHandler, P_Step,
  fun void init(){}

  HANDLE{
    doStep(parent, entries, loop);
  },
  int entries[];
  int loop;
)


genHandler(TrigHandler, P_Trigger,
  fun void init(){}

  HANDLE{
    parent.sendPulse(P_Trigger, entries[parent.getVal("curStep")]);
  },
  int entries[];
)



genHandler(SetHandler, P_Set,
  HANDLE{
    if(null != v){
      v.i => entries[parent.getVal("targetStep")];
      parent.sendPulse(P_Set, parent.getVal("targetStep"));
    }
  },
  int entries[];
)

genHandler(ResetHandler, P_Reset,
  HANDLE{
    parent.setVal("curStep", 0);
  },
  ;
)


public class Sequencer extends Moduck{
  fun static Sequencer make(int entries[], int loop){
    Sequencer ret;
    OUT(P_Trigger);
    OUT(P_Stepped);
    OUT(P_Looped);
    OUT(P_Set);

    IN(StepTrigHandler, (entries, loop));
    IN(StepHandler, (entries, loop));
    IN(TrigHandler, (entries));
    IN(SetHandler, (entries));
    IN(ResetHandler, ());

    ret.addVal("curStep", 0);
    ret.addVal("loop", loop);
    ret.addVal("targetStep", 0);

    return ret;
  }

  fun static Sequencer make(int entries[]){
    return make(entries, true);
  }

}

