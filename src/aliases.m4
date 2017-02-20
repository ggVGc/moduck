
dnl define(V, Patch.connVal($1, null, $2, $3))

define(P, ModuckP.make($1))

define(wrap, P(Wrapper.make($1, $2)))

define(mk, ModuckP.make($1.make(`shift($@)')))


dnl fun Moduck V1(Moduck src, string srcEventName, Moduck target, string msg){
dnl   return Patch.connVal(src, srcEventName, target, msg);
dnl }

fun  Moduck C(Moduck src, Moduck target){
  return Patch.connect(src, target);
}

fun Moduck C(Moduck src, Moduck target, string srcTag){
  return Patch.connect(src, [""], target, [srcTag]);
}

fun Moduck C(Moduck src, string srcTag, Moduck target, string targetTag){
  return Patch.connect(src, [srcTag], target, [targetTag]);
}


dnl fun  Moduck C1(Moduck src, Moduck target, string msg){
dnl   return Patch.connect(src, null, target, msg);
dnl }
dnl
dnl fun  Moduck C2(Moduck src, string srcEventName, Moduck target, string msg){
dnl   return Patch.connect(src, srcEventName, target, msg);
dnl }
dnl
fun ChainData X(Moduck target){
  return ChainData.make(null, target, null);
}

dnl fun ChainData X1(Moduck target, string targetTag){
dnl   return ChainData.make(null, target, targetTag);
dnl }
dnl
dnl fun ChainData X2(string srcTag, Moduck target, string targetTag){
dnl   return ChainData.make(srcTag, target, targetTag);
dnl }

dnl fun ChainData XV(Moduck target, string targetTag){
dnl   return ChainData.val(null, target, targetTag);
dnl }

dnl fun ChainData XV1(string srcTag, Moduck target, string targetTag){
dnl   return ChainData.val(srcTag, target, targetTag);
dnl }

fun Moduck multi(Moduck src, ChainData targets[]){
  return Patch.connectMulti(src, targets);
}

fun Sequencer seq(int ents[]){
  return Sequencer.make(ents, true);
}

fun Moduck chain(Moduck first, ChainData rest[]){
  return Patch.chain(first, rest);
}

