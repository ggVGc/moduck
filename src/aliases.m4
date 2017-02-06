
define(V, Patch.connVal($1, null, $2, $3))


fun Moduck V1(Moduck src, string srcEventName, Moduck target, string msg){
  return Patch.connVal(src, srcEventName, target, msg);
}

fun  Moduck C(Moduck src, Moduck target){
  return Patch.connect(src, null, target, null);
}

fun  Moduck C1(Moduck src, Moduck target, string msg){
  return Patch.connect(src, null, target, msg);
}

fun  Moduck C2(Moduck src, string srcEventName, Moduck target, string msg){
  return Patch.connect(src, srcEventName, target, msg);
}

fun ChainData X(Moduck target){
  return ChainData.conn(null, target, null);
}

fun ChainData X1(Moduck target, string targetTag){
  return ChainData.conn(null, target, targetTag);
}

fun ChainData X2(string srcTag, Moduck target, string targetTag){
  return ChainData.conn(srcTag, target, targetTag);
}

fun ChainData XV(Moduck target, string targetTag){
  return ChainData.val(null, target, targetTag);
}

fun ChainData XV1(string srcTag, Moduck target, string targetTag){
  return ChainData.val(srcTag, target, targetTag);
}

fun Moduck multi(Moduck src, ChainData targets[]){
  return Patch.connectMulti(src, targets);
}

fun Sequencer seq(int ents[]){
  return Sequencer.make(ents, true);
}

fun Moduck chain(Moduck first, ChainData rest[]){
  return Patch.chain(first, rest);
}

