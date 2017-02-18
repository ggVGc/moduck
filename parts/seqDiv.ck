

fun Moduck seqDiv(int lengths[]){
  lengths[0] => int initialDelay;
  int trigLens[lengths.size()-1];
  for(0=>int i;i<trigLens.size();i++){
    lengths[i+1] => trigLens[i];
  }
  def( divider, PulseDiv.make(trigLens[0], 0) )


  def( sequence, S(trigLens, true) )
  C(divider, sequence);
  V( sequence, divider, "divisor");
  if(initialDelay > 0){
    initialDelay +=> trigLens[trigLens.size()-1];
    return C(Buffer.make(initialDelay), Wrapper.make(divider, sequence));
  }else{
    return Wrapper.make(divider, sequence);
  }
}
