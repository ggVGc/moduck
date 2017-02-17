
// Standard pulses

include(pulses.m4)

public class Pulse{
  fun static string Trigger(){ return P_Trigger; }
  fun static string Reset(){ return P_Reset; }
  fun static string Set(){ return P_Set; }
  fun static string Clock(){ return P_Clock; }
  fun static string Looped(){ return P_Looped; }
  fun static string Stepped(){ return P_Stepped; }
  fun static string Step(){ return P_Step; }
  fun static string StepTrigger(){ return P_StepTrigger; }
}
