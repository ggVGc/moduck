
include(macros.m4)


class BufEntry{
  dur timeStamp;
  IntRef val;
  false => int triggered;
}


class Shared{
  Buffer buf;
  BufEntry entries[0];
  false => int clearing;
  time startTime; // gets reset on loop
  time lastTime;
}


genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      now - shared.startTime => dur delta;
      for(0=>int i;i<shared.entries.size();++i){
        shared.entries[i] @=> BufEntry e;
        if(e != null && !e.triggered && e.timeStamp <= delta){
          if(shared.clearing){
            null @=> shared.entries[i];
          }else{
            true => e.triggered;
            parent.send(P_Trigger, e.val);
          }
        }
      }
      now @=> shared.lastTime;
    }
  },
  Shared shared;
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      now => shared.startTime;
      now => shared.lastTime;
      for(0=>int i;i<shared.entries.size();++i){
        if(null != shared.entries[i]){
          false => shared.entries[i].triggered;
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

  },
  Shared shared;
)



genHandler(ClearAllHandler, P_ClearAll,
  HANDLE{
    if(null != v){
      shared.entries.size(0);
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
  maker(Buffer, dur length, int loop){
    Buffer ret;
    Shared shared;
    ret @=> shared.buf;
    OUT(P_Trigger);
    IN(TrigHandler,(shared));
    IN(SetHandler,(shared));
    IN(ClearAllHandler,(shared));
    IN(ClearHandler,(shared));
    IN(ResetHandler,(shared));
    ret.addVal("length", Util.toSamples(length));
    ret.addVal("loop", loop);
    return ret;
  }

  fun static Buffer make(dur length){
    return Buffer.make(length, true);
  }
}

