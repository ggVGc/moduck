include(moduck_macros.m4)
include(song_macros.m4)
include(funcs.m4)



// Play buffer when gate is on.
// Use timeToNext for waits between entries


public class BufPlayer extends Moduck{
  fun static Moduck make(Buffer buf){
    def(in, mk(Repeater, [P_Gate, P_Reset]));
    def(out, mk(Repeater, [P_Looped]));

    return mk(Wrapper, in, out);
  }
}


