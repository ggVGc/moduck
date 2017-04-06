
include(macros.m4)


class BufEntry{
  dur timeStamp;
  IntRef val;
  false => int triggered;
  0 => int index;

}


class Shared{
  Buffer buf;
  BufEntry entries[0];
  false => int clearing;
  time startTime; // gets reset on loop
  now => time lastTime;
  int accum;
}

genHandler(ClockHandler, P_Clock,
  HANDLE{
    if(null != v){
      now - shared.startTime => dur delta;
      for(0=>int i;i<shared.entries.size();++i){
        shared.entries[i] @=> BufEntry e;
        false => int shouldTrigger;
        if(e!=null){
          if(parent.getVal("timeBased")){
            (e.timeStamp <= delta) => shouldTrigger;
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
          }
        }
      }
      now => shared.lastTime;
      ++shared.accum;

      if(shared.clearing){
        true => int allEmpty;
        for(0=>int entInd;entInd<shared.entries.size();++entInd){
          shared.entries[entInd] @=> BufEntry e;
          if(e != null){
            false => allEmpty;
            break;
          }
        }
        if(allEmpty){
          parent.send("hasData", null);
        }
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



genHandler(SetHandler, P_Set,
  HANDLE{
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
    e @=> shared.entries[ind];
    v @=> e.val;

    now - shared.startTime => e.timeStamp;
    shared.accum => e.index;
    parent.send("hasData", IntRef.yes());
  },
  Shared shared;
)



genHandler(ClearAllHandler, P_ClearAll,
  HANDLE{
    if(null != v){
      shared.entries.size(0);
      parent.send("hasData", null);
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


public class Buffer extends Moduck{
  maker0(Buffer){
    Buffer ret;
    Shared shared;
    ret @=> shared.buf;
    OUT(P_Trigger);
    OUT("hasData");
    IN(ClockHandler,(shared));
    IN(SetHandler,(shared));
    IN(ClearAllHandler,(shared));
    IN(ClearHandler,(shared));
    IN(GoToHandler,(shared));
    IN(ResetHandler,(shared));
    ret.addVal("timeBased", false);
    return ret;
  }
}

