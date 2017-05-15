include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)


define(QUANTIZATION, 16)


0 => int Idle;
1 => int RecOffArmed;
2 => int RecOnArmed;
3 => int PlayOnArmed;
4 => int PlayOffArmed;
5 => int Recording;
6 => int Playing;

class Shared{
  ModuckP @ buffer;
  ModuckP @ out;
  ModuckP @ player;
  SampleHold @ hasData;
  Idle => int state;
  0 => int clockCount;
  0 => int quantCounter;
  0 => int bufLenTicks;
  now => time lastTickTime;
  0::ms => dur tickOffset;
}


genHandler(SetHandler, P_Set,
  HANDLE{
    if(RecOnArmed == shared.state){
      shared.buffer.doHandle(P_GoTo, 0);
      Recording => shared.state;
      shared.player.doHandle(P_Gate, IntRef.yes());
      1 => shared.clockCount;
      1 => shared.quantCounter;
      shared.out.send(P_Recording, IntRef.yes());
      now - shared.lastTickTime => shared.tickOffset;
    }
    if(Recording == shared.state){
      shared.buffer.doHandle(P_Set, v);
    }
  },
  Shared shared;
)


genHandler(ClearAllHandler, P_ClearAll,
  HANDLE{
    Idle => shared.state;
    shared.buffer.doHandle(P_ClearAll, v);
    shared.player.doHandle(P_Gate, null);
    0::ms => shared.tickOffset;
  },
  Shared shared;
)


genHandler(ClearHandler, P_Clear,
  HANDLE{
    shared.buffer.doHandle(P_Clear, v);
    0::ms => shared.tickOffset;
  },
  Shared shared;
)



genHandler(ToggleHandler, P_Toggle,
  HANDLE{
    if(v != null){
      if(Recording == shared.state){
        RecOffArmed => shared.state;
      }else{ 
        if(shared.hasData.get() != null){
          if(Playing == shared.state){
            PlayOffArmed => shared.state;
          }else{
            PlayOnArmed => shared.state;
          }
        }else{
          RecOnArmed => shared.state;
        }
      }
    }
  },
  Shared shared;
)


fun void stopRec(Shared shared){
  shared.tickOffset => now;
  shared.buffer.doHandle(P_GoTo, 0);
  /* shared.player.doHandle(P_Gate, IntRef.yes()); */
  shared.out.send(P_Recording, null);
}


fun void reset(Shared shared){
  shared.tickOffset => now;
  shared.buffer.doHandle(P_GoTo, 0);
  /* shared.player.doHandle(P_Gate, IntRef.yes()); */
  shared.out.doHandle(P_Looped, 0);
}


genHandler(ClockHandler, P_Clock,
  HANDLE{
    now => shared.lastTickTime;
  if(Math.fmod(shared.quantCounter, QUANTIZATION) $ int == 0){
    if(RecOffArmed == shared.state){
      shared.clockCount => shared.bufLenTicks;
      0 => shared.clockCount;
      Playing => shared.state;
      spork ~ stopRec(shared);
      // TODO: Enable playback control again
    /* 
     }else if(PlayOnArmed == shared.state){
       0 => shared.clockCount;
       shared.buffer.doHandle(P_GoTo, 0);
       Playing => shared.state;
       shared.player.doHandle(P_Gate, IntRef.yes());
     }else if(PlayOffArmed == shared.state){
       Idle => shared.state;
       shared.player.doHandle(P_Gate, null);
     */
     }
  }

  if(Playing == shared.state){
    if(shared.clockCount >= shared.bufLenTicks){
      0 => shared.clockCount;
      spork ~ reset(shared);
    }
  }

  1 +=> shared.clockCount;
  1 +=> shared.quantCounter;
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
    Value.make(null) @=> shared.hasData;
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

   shared.hasData.doHandle(P_Set, null);


   shared.player => frm(recv(P_Gate)).c => mk(Printer, "Player gate").c;
   /* shared.hasData => mk(Printer, "hasData").c; */
   /* shared.buffer => frm("hasData").c => mk(Printer, "buf hasData").c; */

    return mk(Wrapper, ret, shared.out);
  }
}
