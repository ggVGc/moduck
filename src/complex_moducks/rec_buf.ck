include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)


define(QUANTIZATION, 4)


0 => int NoArm;
1 => int RecOffArmed;
2 => int RecOnArmed;
3 => int PlayArmed;
4 => int Recording;

class Shared{
  ModuckP @ buffer;
  ModuckP @ out;
  ModuckP @ player;
  SampleHold @ playing;
  SampleHold @ hasData;
  NoArm => int state;
  0 => int clockCount;
  0 => int bufLenTicks;
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



genHandler(ToggleHandler, P_Toggle,
  HANDLE{
    if(v != null){
      <<<"TOGGLE">>>;
      
      if(Recording == shared.state){
        RecOffArmed => shared.state;
      <<<"Rec arm OFF">>>;
      }else{ 
        if(shared.hasData.get() != null){
          <<<"Play arm On">>>;
          PlayArmed => shared.state;
        }else{
          <<<"Rec arm On">>>;
          RecOnArmed => shared.state;
        }
      }

      shared.player.doHandle(P_Gate, null);
      shared.buffer.doHandle(P_GoTo, 0);
    }
  },
  Shared shared;
)


genHandler(ClockHandler, P_Clock,
  HANDLE{

    1 +=> shared.clockCount;

    if(Math.fmod(shared.clockCount, QUANTIZATION) $ int == 0){
      if(RecOffArmed == shared.state){
        NoArm => shared.state;
        shared.player.doHandle(P_Gate, IntRef.yes());
        shared.out.send(P_Recording, null);
        shared.clockCount => shared.bufLenTicks;
        0 => shared.clockCount;
      }else if(RecOnArmed == shared.state){
        Recording => shared.state;
        shared.out.send(P_Recording, IntRef.yes());
        shared.player.doHandle(P_Gate, IntRef.yes());
        0 => shared.clockCount;
      }else if(PlayArmed == shared.state){
        0 => shared.clockCount;
        if(shared.playing.get() != null){
          shared.player.doHandle(P_Gate, null);
        }else{
          shared.player.doHandle(P_Gate, IntRef.yes());
        }
      }
      NoArm => shared.state;
    }

    if(NoArm == shared.state && shared.playing.get() != null){
      if(shared.clockCount >= shared.bufLenTicks-1){
        0 => shared.clockCount;
        shared.buffer.doHandle(P_GoTo, 0);
        shared.out.doHandle(P_Looped, 0);
      }
    }
  },
  Shared shared;
)



public class RecBuf{
  fun static Moduck make(int quantization){
    Moduck ret;

    Shared shared;

    Buffer.make() @=> Buffer buf;
    P(buf) @=> shared.buffer;
    mk(BufPlayer, buf) @=> shared.player;
    shared.buffer.doHandle("timeBased", true);
    Value.make(null) @=> shared.playing;
    Value.make(null) @=> shared.hasData;
    shared.playing.doHandle("triggerOnSet", IntRef.yes());
    shared.hasData.doHandle("triggerOnSet", IntRef.yes());

    P(Repeater.make([
      P_Trigger
      ,P_Recording
      ,P_Playing
      ,P_Looped 
      ,"hasData"])) @=> shared.out;

    IN(SetHandler, (shared));
    IN(ClearAllHandler, (shared));
    IN(ToggleHandler, (shared));
    IN(ClearHandler, (shared));
    IN(ClockHandler, (shared));

    shared.buffer => shared.out.listen([P_Trigger, "hasData"]).c;
    Patch.connect(shared.buffer, "hasData", shared.hasData, P_Set);

   shared.player => shared.out.fromTo(recv(P_Gate), P_Playing).c;
   Patch.connect(shared.player, recv(P_Gate), shared.playing, P_Set);

   samp => now;
   shared.playing.doHandle(P_Set, null);
   shared.hasData.doHandle(P_Set, null);


   shared.player => frm(recv(P_Gate)).c => mk(Printer, "Player gate").c;
   shared.hasData => mk(Printer, "hasData").c;
   shared.buffer => frm("hasData").c => mk(Printer, "buf hasData").c;
   shared.playing => mk(Printer, "playing").c;

    return mk(Wrapper, ret, shared.out);
  }
}
