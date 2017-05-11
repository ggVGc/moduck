
fun ModuckP fourFour(int beatLen, int val){
  return P(C(PulseDiv.make(beatLen), Value.make(val)));
}

fun ModuckP fourFour(int beatLen){
  return fourFour(beatLen, 0);
}




