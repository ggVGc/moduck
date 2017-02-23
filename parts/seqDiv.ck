

fun ModuckP seqDiv(int lengths[]){
  lengths[0] => int initialDelay;
  int trigLens[lengths.size()-1];
  for(0=>int i;i<trigLens.size();i++){
    lengths[i+1] => trigLens[i];
  }
  def( divider, PulseDiv.make(trigLens[0], 0))
  "seqDiv_div" @=> divider.name;


  def( sequence, S(trigLens, true).setName("seqDiv_seq") )
  C(divider, sequence);
  C( sequence, divider, "divisor");
  Wrapper.make(divider, sequence) @=> Moduck ret;

  divider => sequence.from(recv(P_Reset)).to(P_Reset).c;

  if(initialDelay > 0){
    initialDelay +=> trigLens[trigLens.size()-1];
    def(buf, Buffer.make(initialDelay))
    "seqDiv_buf" @=> buf.name;
    C(buf, recv(P_Reset), ret, P_Reset);
    C(buf, ret) @=> ret;
  }
  return ModuckP.make(ret);
}

fun ModuckP seqDiv(string pattern, int beatSize, int totalLen){
  Util.seqFromString(pattern, beatSize, totalLen) @=> SeqInfo info;
  def(div, seqDiv(info.lens))
  def(numSeq, mk(Sequencer, info.nums, true).setName("seqDiv_numSeq"))

  div => numSeq.from(recv(P_Reset)).to(P_Reset).c;

  return div => numSeq.c;
}
