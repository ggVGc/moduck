

// TODO: Lots of functioknality is scrapped/broken/commented out
// Fix up when/if needed. Multiple inputs(tags) is disabled. 
// Same for on the fly clearing and index-based sequencing.

include(moduck_macros.m4)


define(quantStepsPerBeat, 16);



class BufEntry{
  dur timeStamp;
  int val;
  0::ms => dur length;
  false => int triggered;
  false => int endTriggered;
  /* 0 => int index; */
  /* string tag; */
}


class Shared{
  BufEntry entries[0];
  /* false => int clearing; */
  time startTime; // gets reset on loop
  /* now => time lastTime; */
  /* int accum; */
  false => BOOL lenMultiplierChanged;
  null @=> BufEntry lastTriggeredEntry;
}



fun dur calcTimeToNext(dur start, BufEntry entries[], int useCached, int includeTriggered){
  return 1::ms;
  /* false => BOOL found; */
  /* dur smallest; */
  /* for(0=>int entInd;entInd<entries.size();++entInd){ */
  /*   entries[entInd] @=> BufEntry e; */
  /*   if(includeTriggered || !e.triggered){ */
  /*     dur t; */
  /*     if(useCached){ */
  /*       e.cachedTimestamp => t; */
  /*     }else{ */
  /*       e.timeStamp => t; */
  /*     } */
  /*     if(t > start){ */
  /*       if(!found){ */
  /*         t - start => smallest; */
  /*       }else{ */
  /*         t - start => dur d; */
  /*         if(d < smallest){ */
  /*           d => smallest; */
  /*         } */
  /*       } */
  /*     } */
  /*   } */
  /* } */
  /* if(found){ */
  /*   return smallest; */
  /* }else{ */
  /*   return 1::ms; */
  /* } */
}



/* fun dur calcEntryTime(BufEntry e, BufEntry allEntries[], int lengthRatio){ */
/*   if(e.val != null){ */
/*     return e.timeStamp; */
/*   }else{ */
/*     if(lengthRatio != 100){ */
/*       lastOnEventTimeBefore(e.timeStamp, allEntries) =>  dur onTime; */
/*       e.timeStamp - onTime => dur delta; */
/*       onTime + ((lengthRatio $ float)/100.0)*delta => dur newTime; */
/*       /*  */
/*        calcTimeToNext(onTime, allEntries, false, true) => dur nextTime; */
/*        if(nextTime < newTime){ */
/*          nextTime=> newTime; */
/*        } */
/*        */ 
/*       return newTime; */
/*     }else{ */
/*       return e.timeStamp; */
/*     } */
/*   } */
/* } */





/* 
 fun dur lastOnEventTimeBefore(dur end, BufEntry entries[]){
   0::ms => dur ret;
   for(0=>int elemInd;elemInd<entries.size();++elemInd){
     entries[elemInd] @=> BufEntry e;
     if(e.val != null && e.timeStamp < end && e.timeStamp > ret){
       e.timeStamp => ret;
     }
   }
   return ret;
 }
 */

fun BOOL allEmpty(Shared shared){
  true => int ret;
  for(0=>int entInd;entInd<shared.entries.size();++entInd){
    shared.entries[entInd] @=> BufEntry e;
    if(e != null){
      false => ret;
      break;
    }
  }
  return ret;
}


fun void recalculateLengths(BufEntry entries[], int lengthRatio){
  for(0=>int elemInd;elemInd<entries.size();++elemInd){
    entries[elemInd] @=> BufEntry e;
    /* calcEntryTime(e, entries, lengthRatio) => e.cachedTimestamp; */
  }
}


fun IntRef shouldTriggerEntry(BufEntry e, dur passedTimeSinceStart, Shared shared, ModuckBase parent){
  //if(parent.getVal("timeBased")){

  /* }else{ */
    /* 
     if(e.index <= shared.accum){
       return IntRef.make(e.val);
     }
     */
  /* } */
}



genHandler(ClockHandler, P_Clock,
  HANDLE{
    /* 
     if(shared.lenMultiplierChanged){
       false => shared.lenMultiplierChanged;
       recalculateLengths(shared.entries, parent.getVal("lengthMultiplier"));
     }
     */


    if(null != v){
      now - shared.startTime => dur passedTimeSinceStart;

      false => int shouldTrigger;
      null @=> BufEntry trigEntry;
      0::ms => dur latestTrigTime;
      for(0=>int i;i<shared.entries.size();++i){
        shared.entries[i] @=> BufEntry e;
        if(e != null){
          (parent.getVal("timeMul") $ float )/100.0 => float timeMul;
          e.timeStamp * timeMul => dur t;
          (t + (e.length*(parent.getVal("lengthMultiplier") $ float)/100.0)) => dur endTime;
          if(!e.triggered && t <= passedTimeSinceStart && t >= latestTrigTime){
            true => shouldTrigger;
            true => e.triggered;
            e @=> trigEntry;
            t => latestTrigTime;
          }else if(!e.endTriggered && e == shared.lastTriggeredEntry && e.length != 0::ms && endTime <= passedTimeSinceStart){
            true => shouldTrigger;
            true => e.endTriggered;
          }
        }
      }

      if(shouldTrigger){
        if(trigEntry != null){
          parent.send(P_Trigger, IntRef.make(trigEntry.val));
          trigEntry @=> shared.lastTriggeredEntry;
        }else{
          parent.send(P_Trigger, null);
          null @=> shared.lastTriggeredEntry;
        }
      }

      /* if(shouldTrigger && trigVal != null){ */
      /*   if(shared.clearing){ */
      /*     null @=> shared.entries[i]; */
      /*   }else{ */
      /*     true => e.triggered; */
      /*     parent.send(P_Trigger, IntRef.make(e.val)); */
      /*     if(e.tag != null){ */
      /*       parent.send(e.tag, IntRef.make(e.val)); */
      /*   } */
      /* } */

      /* now => shared.lastTime; */
      /* ++shared.accum; */

      /* 
       if(shared.clearing && allEmpty(shared)){
         parent.send("hasData", null);
       }
       */
    }
  },
  Shared shared;
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      now => shared.startTime;
      null @=> shared.lastTriggeredEntry;
      /* now => shared.lastTime; */
      /* 0 => shared.accum; */
      for(0=>int i;i<shared.entries.size();++i){
        if(null != shared.entries[i]){
          false => shared.entries[i].triggered;
          false => shared.entries[i].endTriggered;
        }
      }
    }
    parent.send("hasData", null);
    parent.send(P_Trigger, null);
  },
  Shared shared;
)


genHandler(GoToHandler, P_GoTo,
  HANDLE{
    if(null != v){
      now => shared.startTime;
      null @=> shared.lastTriggeredEntry;
      /* now => shared.lastTime; */
      /* v.i => shared.accum; */
      for(0=>int i;i<shared.entries.size();++i){
        if(null != shared.entries[i]){
          /* (i < shared.accum) => shared.entries[i].triggered; */
          false => shared.entries[i].triggered;
          false => shared.entries[i].endTriggered;
        }
      }
    }
  },
  Shared shared;
)



function void set(int v, ModuckBase parent, Shared shared, string tag){
    -1 => int ind;
    for(0=>int i;i<shared.entries.size();++i){
      if(shared.entries[i] == null){
        i => ind;
        break;
      }
    }
    if(ind == -1){
      shared.entries.size(shared.entries.size()+1);
      shared.entries.size()-1 => ind;
    }
    BufEntry e;
    true => e.triggered;
    true => e.endTriggered;
    0::ms => e.length;
    e @=> shared.entries[ind];
    v => e.val;
    /* tag => e.tag; */

    now - shared.startTime => e.timeStamp;


    Util.toSamples(minute / (Runner.getBpm()*quantStepsPerBeat)) => float quantizeStep;
    Util.toSamples(e.timeStamp) / quantizeStep => float steps;
    Math.floor(steps) $ int => int whole;
    if(steps-whole < 0.5){
      (whole * quantizeStep)::samp => e.timeStamp;
    }else{
      ((whole+1)* quantizeStep)::samp => e.timeStamp;
    }

    /* calcEntryTime(e, shared.entries, parent.getVal("lengthMultiplier")) => e.cachedTimestamp; */

    /* shared.accum => e.index; */
    parent.send("hasData", IntRef.yes());
}

fun BufEntry findLastEntry(BufEntry entries[]){
  null => BufEntry last;
  0::samp => dur lastTime;
  for(0=>int elemInd;elemInd<entries.size();++elemInd){
    entries[elemInd] @=> BufEntry e;
    if(e != null && e.timeStamp >= lastTime){
      e @=> last;
      e.timeStamp => lastTime;
    }
  }
  return last;
}

genHandler(SetHandler, P_Set,
  HANDLE{
    findLastEntry(shared.entries) @=> BufEntry last;
    if(last != null && last.length == 0::ms){
      (now - shared.startTime) - last.timeStamp => last.length;
      <<<Util.toSamples(last.length)>>>;
    }
    if(v != null){
      set(v.i, parent, shared, null);
    }
  },
  Shared shared;
)



genHandler(ClearAllHandler, P_ClearAll,
  HANDLE{
    if(null != v){
      shared.entries.size(0);
      parent.send("hasData", null);
      parent.send(P_Trigger, null);
    }
  },
  Shared shared;
)



genHandler(ClearHandler, P_Clear,
  HANDLE{
    /* (v != null) => shared.clearing; */
  },
  Shared shared;
)


//TODO: Implement again, when multiple tags are needed
genTagHandler(TagSetHandler, 
    HANDLE{
      /* set(v, parent, shared, tag); */
    },
  Shared shared;
)



public class Buffer extends Moduck{

  Shared shared;

  fun dur timeToNext(){
    if(shared.lenMultiplierChanged){
      false => shared.lenMultiplierChanged;
      recalculateLengths(shared.entries, getVal("lengthMultiplier"));
    }
    return calcTimeToNext(now - shared.startTime, shared.entries, true, false);
  }

  fun void onValueChange(string key, int oldVal, int newVal){
    if(key == "lengthMultiplier"){
      true => shared.lenMultiplierChanged;
    }
  }


  fun static Buffer make(){
    string tags[0];
    return make(tags);
  }

  fun static Buffer make(string tags[]){
    Buffer ret;
    OUT(P_Trigger);
    OUT("hasData");
    for(0=>int tagInd;tagInd<tags.size();++tagInd){
      tags[tagInd] @=> string tag;
      IN(TagSetHandler, (tag, ret.shared));
      OUT(tag);
    }
    IN(ClockHandler,(ret.shared));
    IN(SetHandler,(ret.shared));
    IN(ClearAllHandler,(ret.shared));
    IN(ClearHandler,(ret.shared));
    IN(GoToHandler,(ret.shared));
    IN(ResetHandler,(ret.shared));
    /* ret.addVal("timeBased", false); */
    ret.addVal("lengthMultiplier", 100);
    ret.addVal("timeMul", 100);
    return ret;
  }
}

