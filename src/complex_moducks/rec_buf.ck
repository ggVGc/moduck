include(song_macros.m4)
include(funcs.m4)




public class RecBuf{
  fun static Moduck make(int quantization){
    def(in, mk(Repeater, Util.concatStrings([[
      P_Clock
      ,P_Set
      ,P_ClearAll
      ,P_Clear
      ,P_Toggle
    ]])));

    def(out, mk(Repeater, Util.concatStrings([[
      P_Trigger
      ,P_Recording
      ,P_Playing
      ,P_Looped
      ,"hasData"
    ]])));

    return mk(Wrapper, in, out);
  }
}
