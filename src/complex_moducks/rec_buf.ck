include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)


0 => int NoArm;
1 => int RecOffArmed;
2 => int RecOnArmed;
3 => int PlayArmed;
4 => int Recording;

class Shared{
  Buffer @ buffer;
  Moduck @ out;
  Moduck @ player;
  SampleHold @ playing;
  int state;
}


genHandler(SetHandler, P_Set,
  HANDLE{
    if(Recording == shared.state){
        shared.buffer.doHandle(P_Set, v);
    }
  },
  Shared shared;
)


genHandler(ClearAllHandler, P_ClearAll,
  HANDLE{
    shared.buffer.doHandle(P_ClearAll, v);
    shared.player.doHandle(P_Gate, null);
  },
  Shared shared;
)


genHandler(ClearHandler, P_Clear,
  HANDLE{
    shared.buffer.doHandle(P_Clear, v);
  },
  Shared shared;
)



// If we don't have any data, toggle recording
// Otherwise toggle playback
genHandler(ToggleHandler, P_Toggle,
  HANDLE{
    V(hasData)
    if(Recording == shared.state){
      RecOffArmed => shared.state;
    }else{ 
      if(hasData){
        PlayArmed => shared.state;
      }else{
        RecOnArmed => shared.state;
      }
    }

    shared.player.doHandle(P_Gate, null);
    shared.buffer.doHandle(P_GoTo, 0);
  },
  Shared shared;
)


genHandler(ClockHandler, P_Clock,
  HANDLE{
    if(RecOffArmed == shared.state){
      NoArm => shared.state;
      shared.player.doHandle(P_Gate, IntRef.yes());
      shared.out.send(P_Recording, null);
    }else if(RecOnArmed == shared.state){
      Recording => shared.state;
      shared.out.send(P_Recording, IntRef.yes());
      shared.player.doHandle(P_Gate, IntRef.yes());
    }else if(PlayArmed == shared.state){
      if(shared.playing.get() != null){
        shared.player.doHandle(P_Gate, null);
      }else{
        shared.player.doHandle(P_Gate, IntRef.yes());
      }
      NoArm => shared.state;
    }
  },
  Shared shared;
)



public class RecBuf{
  fun static Moduck make(int quantization){
    Moduck ret;

    Shared shared;

    Buffer.make() @=> shared.buffer;
    BufPlayer.make(shared.buffer) @=> shared.player;
    shared.buffer.doHandle("timeBased", true);
    Value.make(null) @=> shared.playing;
    shared.playing.doHandle("triggerOnSet", IntRef.yes());

    Repeater.make([
      P_Trigger
      ,P_Recording
      ,P_Playing
      ,P_Looped 
      ,"hasData"]) @=> shared.out;

    IN(SetHandler, (shared));
    IN(ClearAllHandler, (shared));
    IN(ToggleHandler, (shared));
    IN(ClearHandler, (shared));
    IN(ClockHandler, (shared));

    P(shared.buffer) => P(shared.out).listen([P_Trigger, "hasData"]).c;
    P(shared.player)
      .b(P(shared.out).listen([P_Looped]).fromTo(recv(P_Gate), P_Playing))
      .b(P(shared.playing).fromTo(recv(P_Gate), P_Set));

    return mk(Wrapper, ret, shared.out);
  }
}
