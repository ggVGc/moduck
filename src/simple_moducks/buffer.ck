
include(moduck_macros.m4)


define(quantStepsPerBeat, 8);



class BufEntry{
  dur timeStamp;
  IntRef val;
  false => int triggered;
  0 => int index;
  string tag;
}


// TODO: Cache this and only recalculate if lengthMultiplier changed
fun dur getTime(BufEntry e, BufEntry allEntries[], int lengthRatio){
  if(e.val != null){
    return e.timeStamp;
  }else{
    if(lengthRatio != 100){
      lastOnEventTimeBefore(e.timeStamp, allEntries) =>  dur onTime;
      e.timeStamp - onTime => dur delta;
      return onTime + ((lengthRatio $ float)/100.0)*delta;
    }else{
      return e.timeStamp;
    }
  }
}


class Shared{
  BufEntry entries[0];
  false => int clearing;
  time startTime; // gets reset on loop
  now => time lastTime;
  int accum;
}




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


genHandler(ClockHandler, P_Clock,
  HANDLE{
    if(null != v){
      now - shared.startTime => dur passedTimeSinceStart;
      for(0=>int i;i<shared.entries.size();++i){
        shared.entries[i] @=> BufEntry e;
        false => int shouldTrigger;
        if(e!=null){
          if(parent.getVal("timeBased")){
            (getTime(e, shared.entries, parent.getVal("lengthMultiplier")) <= passedTimeSinceStart) => shouldTrigger;
          }else{
            (e.index <= shared.accum) => shouldTrigger;
          }
        }
        if(shouldTrigger && !e.triggered){
          if(shared.clearing){
            null @=> shared.entries[i];
          }else{
            true => e.triggered;
            parent.send(P_Trigger, e.val);
            if(e.tag != null){
              parent.send(e.tag, e.val);
            }
          }
        }
      }

      now => shared.lastTime;
      ++shared.accum;

      if(shared.clearing && allEmpty(shared)){
        parent.send("hasData", null);
      }
    }
  },
  Shared shared;
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      now => shared.startTime;
      now => shared.lastTime;
      0 => shared.accum;
      for(0=>int i;i<shared.entries.size();++i){
        if(null != shared.entries[i]){
          false => shared.entries[i].triggered;
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
      now => shared.lastTime;
      v.i => shared.accum;
      for(0=>int i;i<shared.entries.size();++i){
        if(null != shared.entries[i]){
          (i < shared.accum) => shared.entries[i].triggered;
        }
      }
    }
  },
  Shared shared;
)



function void set(IntRef v, ModuckBase parent, Shared shared, string tag){
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
    e @=> shared.entries[ind];
    v @=> e.val;
    tag => e.tag;

    now - shared.startTime => e.timeStamp;

    if(v != null){
      Util.toSamples(minute / (Runner.getBpm()*quantStepsPerBeat)) => float quantizeStep;
      Util.toSamples(getTime(e, shared.entries, parent.getVal("lengthMultiplier"))) / quantizeStep => float steps;
      Math.floor(steps) $ int => int whole;
      if(steps-whole < 0.5 && v != null){
        (whole * quantizeStep)::samp => e.timeStamp;
      }else{
        ((whole+1)* quantizeStep)::samp => e.timeStamp;
      }
    }
    
    /* 
     if(v != null){ // off event
       lastOnEventTimeBefore(getTime(e, shared.entries), shared) => dur last;
       if(last != 0::ms && last == getTime(e, shared.entries)){
         getTime(e, shared.entries) + (quantizeStep)::samp => e.timeStamp;
       }
     }
     */




    shared.accum => e.index;
    parent.send("hasData", IntRef.yes());
}

genHandler(SetHandler, P_Set,
  HANDLE{
    set(v, parent, shared, null);
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
    (v != null) => shared.clearing;
  },
  Shared shared;
)


genTagHandler(TagSetHandler, 
    HANDLE{
    if(v != null){
        <<<"Set: "+tag+":"+v.i>>>;
    }else{
        <<<"Set: "+tag+":null">>>;
    }
      set(v, parent, shared, tag);
    },
  Shared shared;
)




public class Buffer extends Moduck{

  Shared shared;

  fun dur timeToNext(){
    false => BOOL found;
    dur smallest;
    now - shared.startTime => dur passedTimeSinceStart;
    for(0=>int entInd;entInd<shared.entries.size();++entInd){
      shared.entries[entInd] @=> BufEntry e;
      if(!e.triggered){
        if(!found){
          getTime(e, shared.entries, getVal("lengthMultiplier")) - passedTimeSinceStart => smallest;
        }else{
          getTime(e, shared.entries, getVal("lengthMultiplier")) - passedTimeSinceStart => dur d;
          if(d < smallest){
            d => smallest;
          }
        }
      }
    }
    if(found){
      return smallest;
    }else{
      return 1::ms;
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
    ret.addVal("timeBased", false);
    ret.addVal("lengthMultiplier", 100);
    return ret;
  }
}

