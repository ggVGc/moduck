include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)



class Shared{
  ModuckP @ buffer;
  ModuckP @ out;
  ModuckP @ player;
  SampleHold @ hasData;
  RecBuf.Idle => int state;
  0 => int clockCount;
  0 => int quantCounter;
  0 => int bufLenTicks;
  0 => int quantization;
  now => time lastTickTime;
  0::ms => dur tickOffset;
}

fun void changeState(int newState, Shared shared){
  <<<"New State"+newState>>>;
  newState => shared.state;
  shared.out.send("state", IntRef.make(newState));
}


genHandler(SetHandler, P_Set,
  HANDLE{
    if(RecBuf.RecOnArmed == shared.state){
      shared.buffer.doHandle(P_GoTo, 0);
      changeState(RecBuf.Recording,  shared);
      shared.player.doHandle(P_Gate, IntRef.yes());
      1 => shared.clockCount;
      1 => shared.quantCounter;
      now - shared.lastTickTime => shared.tickOffset;
    }
    if(RecBuf.Recording == shared.state || RecBuf.RecOffArmed == shared.state){
      shared.buffer.doHandle(P_Set, v);
    }
  },
  Shared shared;
)


genHandler(ClearAllHandler, P_ClearAll,
  HANDLE{
    changeState(RecBuf.Idle, shared);
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
      if(RecBuf.Recording == shared.state){
        changeState(RecBuf.RecOffArmed, shared);
      }else{ 
        if(shared.hasData.get() != null){
          if(RecBuf.Playing == shared.state){
            changeState(RecBuf.PlayOffArmed, shared);
          }else{
            changeState(RecBuf.PlayOnArmed, shared);
          }
        }else{
          changeState(RecBuf.RecOnArmed, shared);
        }
      }
    }
  },
  Shared shared;
)



genHandler(ClockHandler, P_Clock,
  HANDLE{
    now => shared.lastTickTime;
  if(Math.fmod(shared.quantCounter, shared.quantization) $ int == 0){
    if(RecBuf.RecOffArmed == shared.state){
      shared.clockCount => shared.bufLenTicks;
      0 => shared.clockCount;
      shared.tickOffset => now;
      changeState(RecBuf.Playing, shared);
      shared.buffer.doHandle(P_GoTo, 0);
    }else if(RecBuf.PlayOnArmed == shared.state){
      0 => shared.clockCount;
      shared.tickOffset => now;
      changeState(RecBuf.Playing, shared);
      shared.buffer.doHandle(P_GoTo, 0);
      shared.player.doHandle(P_Gate, IntRef.yes());
    }else if(RecBuf.PlayOffArmed == shared.state){
      shared.tickOffset => now;
      changeState(RecBuf.Idle, shared);
      shared.player.doHandle(P_Gate, null);
    }
  }

  if(RecBuf.Playing == shared.state){
    if(shared.clockCount >= shared.bufLenTicks){
      0 => shared.clockCount;
      shared.tickOffset => now;
      shared.buffer.doHandle(P_GoTo, 0);
      shared.out.doHandle(P_Looped, 0);
    }
  }

  1 +=> shared.clockCount;
  1 +=> shared.quantCounter;
  },
  Shared shared;
)



public class RecBuf{
  static int Idle;
  static int RecOffArmed;
  static int RecOnArmed;
  static int PlayOnArmed;
  static int PlayOffArmed;
  static int Recording;
  static int Playing;


  fun static Moduck make(int quantization){
    Moduck ret;

    Shared shared;
    quantization => shared.quantization;

    Buffer.make() @=> Buffer buf;
    P(buf) @=> shared.buffer;
    mk(BufPlayer, buf) @=> shared.player;
    shared.buffer.doHandle("timeBased", true);
    Value.make(null) @=> shared.hasData;
    shared.hasData.doHandle("triggerOnSet", IntRef.yes());

    P(Repeater.make([
      P_Trigger
      ,P_Looped 
      ,"state"
      ,"hasData"])) @=> shared.out;

    IN(SetHandler, (shared));
    IN(ClearAllHandler, (shared));
    IN(ToggleHandler, (shared));
    IN(ClearHandler, (shared));
    IN(ClockHandler, (shared));

    shared.buffer => shared.out.listen([P_Trigger, "hasData"]).c;
    Patch.connect(shared.buffer, "hasData", shared.hasData, P_Set);

   /* shared.player => shared.out.fromTo(recv(P_Gate), P_Playing).c; */

   shared.hasData.doHandle(P_Set, null);


   shared.player => frm(recv(P_Gate)).c => mk(Printer, "Player gate").c;
   /* shared.hasData => mk(Printer, "hasData").c; */
   /* shared.buffer => frm("hasData").c => mk(Printer, "buf hasData").c; */

    return mk(Wrapper, ret, shared.out);
  }
}


0 => RecBuf.Idle;
1 => RecBuf.RecOffArmed;
2 => RecBuf.RecOnArmed;
3 => RecBuf.PlayOnArmed;
4 => RecBuf.PlayOffArmed;
5 => RecBuf.Recording;
6 => RecBuf.Playing;
