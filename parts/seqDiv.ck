

fun Moduck seqDiv(int lengths[]){
  def( divider, PulseDiv.make(lengths[0], 0) )
  def( sequence, S(lengths, true) )
  C(divider, sequence);
  V( sequence, divider, "divisor");
  return Wrapper.make(divider, sequence);
}
