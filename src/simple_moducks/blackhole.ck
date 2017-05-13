
include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger, HANDLE{}, ;)

public class Blackhole extends Moduck{

  fun static Blackhole make(){
    Blackhole ret;
    IN(TrigHandler, ());
    return ret;
  }
}

