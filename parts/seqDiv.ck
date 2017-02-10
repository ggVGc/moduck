

fun Moduck seqDiv(int lengths[]){
  def( divider, PulseDiv.make(lengths[0], 0) )
  def( sequence, S(lengths, true) )
  Repeater.make() @=> Repeater repOut;
  C(divider, repOut);
  C(repOut, C(Delay.make(samp), sequence));
  V( sequence, divider, "divisor");
  // C2(divider, "divisor", repOut, null);
  return Wrapper.make(divider, repOut);
}
