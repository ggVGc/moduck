include(moduck_macros.m4)


fun void doStep(ModuckBase parent, int entries[], int loop){
  parent.getVal("curStep") => int lastCurStep;


  false => int looped;
  if(lastCurStep == parent.getVal("length") - 1){
    if(parent.getVal("loop")){
      parent.setVal("curStep", 0);
    /* <<<"Seq looped">>>; */
      true => looped;
    }
  }else{
    /* <<<"Seq Stepped">>>; */
    parent.setVal("curStep", lastCurStep + 1);
  }

  if(lastCurStep < entries.size()){
    entries[lastCurStep] => int v;
    parent.sendPulse(P_Stepped, v);
    if(looped){
      parent.sendPulse(P_Looped, v);
    }
  }
}

fun void doTrigger(ModuckBase parent, int entries[]){
  V(curStep)
  <<<"SIZE: "+entries.size()>>>;
  if(curStep < entries.size()){
    <<<"CUR: "+entries[curStep]>>>;
    parent.sendPulse(P_Trigger, entries[curStep]);
  }
}


genHandler(StepTrigHandler, P_StepTrigger,
  fun void init(){}

  HANDLE{
    if(null != v){
      doTrigger(parent, entries);
      doStep(parent, entries, loop);
    }
  },
  int entries[];
  int loop;
)


genHandler(StepHandler, P_Step,
  fun void init(){}

  HANDLE{
    if(null != v){
      doStep(parent, entries, loop);
    }
  },
  int entries[];
  int loop;
)


genHandler(TrigHandler, P_Trigger,
  fun void init(){}

  HANDLE{
    if(null != v){
      doTrigger(parent, entries);
    }
  },
  int entries[];
)



genHandler(SetHandler, P_Set,
  HANDLE{
    if(null != v){
      <<< "SET: "+v.i >>>;
      V(targetStep)
      if(targetStep >= entries.size()){
        entries.size(targetStep+1);
      }
      v.i => entries[targetStep];
      parent.sendPulse(P_Set, targetStep);
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
    ret.addVal("loop", loop); // Loop or not
    ret.addVal("targetStep", 0); // Step index which will be set from P_Set signal
    ret.addVal("length", entries.size()); // Step index which will be set from P_Set signal

    return ret;
  }

  fun static Sequencer make(int entries[]){
    return make(entries, true);
  }

}

