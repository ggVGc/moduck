define(P_Trigger, "trigger")
define(P_Reset, "reset")
define(P_Set, "set")
define(P_Clock, "clock")
define(P_Looped, "looped")
define(P_Stepped, "stepped")
define(P_Step, "step")
define(P_StepTrigger, "steptrigger")
define(P_Default, "")

define(pulseRecvPrefix, "received_")

define(recv, (pulseRecvPrefix+$1))

fun int isRecvPulse(string str){
  pulseRecvPrefix.length() => int prefLen;
  return str.length() > prefLen
    && str.substring(0, prefLen) == pulseRecvPrefix;
}

fun string[] filterNonRecvPulses(string tags[]){
  string ret[0];
  for(0=>int i;i<tags.size();++i){
    tags[i] @=> string k;
    if(!isRecvPulse(k)){
      ret << k;
    }
  }
  return ret;
}


fun string[] filterRecvPulses(string tags[]){
  string ret[0];
  for(0=>int i;i<tags.size();++i){
    tags[i] @=> string k;
    if(isRecvPulse(k)){
      ret << k;
    }
  }
  return ret;
}
