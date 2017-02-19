

fun ModuckP seqDiv(int lengths[]){
  lengths[0] => int initialDelay;
  int trigLens[lengths.size()-1];
  for(0=>int i;i<trigLens.size();i++){
    lengths[i+1] => trigLens[i];
  }
  def( divider, PulseDiv.make(trigLens[0], 0) )


  def( sequence, S(trigLens, true) )
  C(divider, sequence);
  V( sequence, divider, "divisor");
  Wrapper.make(divider, sequence) @=> Moduck x;
  x @=> Moduck ret;
  if(initialDelay > 0){
    initialDelay +=> trigLens[trigLens.size()-1];
    C(Buffer.make(initialDelay), x) @=> ret;
  }
  return ModuckP.make(ret);
}

fun ModuckP seqDiv(string pattern, int beatSize, int totalLen){
  Util.seqFromString(pattern, beatSize, totalLen) @=> SeqInfo info;
  return ModuckP.make(C(seqDiv(info.lens), Sequencer.make(info.nums, true)));
}
