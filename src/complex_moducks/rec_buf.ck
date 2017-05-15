include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)


class Shared{
  Moduck @ buffer;
  Moduck @ out;
}


genHandler(SetHandler, P_Set,
  HANDLE{
    shared.buffer.doHandle(P_Set, v);
  },
  Shared shared;
)


genHandler(ClearAllHandler, P_ClearAll,
  HANDLE{
    shared.buffer.doHandle(P_ClearAll, v);
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
  },
  Shared shared;
)


genHandler(ClockHandler, P_Clock,
  HANDLE{
  },
  Shared shared;
)



public class RecBuf{
  fun static Moduck make(int quantization){
    Moduck ret;

    Shared shared;

    Buffer.make() @=> shared.buffer;
    shared.buffer.doHandle("timeBased", true);

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

    Patch.connect(shared.buffer, P_Trigger, shared.out, P_Trigger);
    Patch.connect(shared.buffer, "hasData", shared.out, "hasData");

    return mk(Wrapper, ret, shared.out);
  }
}
