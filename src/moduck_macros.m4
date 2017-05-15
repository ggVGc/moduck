

ifdef(`MODUCK_MACROS_INCLUDED',,`define(MODUCK_MACROS_INCLUDED,1)dnl
include(macros.m4)

define(genHandler,
  class $1 extends EventHandler{
    `esyscmd(../intersperse.py ";" "$4")';
    dnl fun void handle(int v)
      $3
    

    fun static $1 make(`esyscmd(../intersperse.py `","' "$4")'){
      $1 ret;
      `esyscmd(../gen_assignments.py "$4")'
      ret.init();
      return ret;
    }

    fun $1 add(Moduck parent){
      parent.addIn($2, this);
      return this;
    }

    dnl fun void addDefault(Moduck parent){
    dnl   parent.addDefaultIn($2, this);
    dnl }

  }
)

define(genTagHandler, 
  class $1 extends EventHandler{
    string tag;

    `esyscmd(../intersperse.py ";" "$3")';
      $2
    

    fun static $1 make(string tag, `esyscmd(../intersperse.py `","' "$3")'){
      $1 ret;
      tag => ret.tag;
      `esyscmd(../gen_assignments.py "$3")'
      ret.init();
      return ret;
    }

    fun $1 add(Moduck parent){
      parent.addIn(tag, this);
      return this;
    }
  }
)


dnl define(genHandler2,
dnl   genHandler(H_$1, P_$1, $2, $3)
dnl )


define(IN, $1.make $2 .add(ret))
define(OUT, ret.addOut($1);)

dnl define(IN_Default, $1.make $2 .addDefault(ret);)
dnl define(OUT_Default, ret.addDefaultOut($1);)


define(HANDLE, fun void handle(IntRef v))

define(V, parent.getVal("$1") @=> int $1;)

define(maker0,

fun static Moduck[] many(int count){
  Moduck ret[count];
  for(0=>int x;x<count;++x){
    make() @=> ret[x];
  }
  return ret;
}


fun static $1 make()
)

define(maker,

fun static Moduck[] many(int count, `shift($@)'){
  Moduck ret[count];
  for(0=>int x;x<count;++x){
    make(
      dnl Extract argument names with some dirty inline python
      `esyscmd(python -c "print(\",\".join(\" $@ \".replace(\",\", \" \").split()[2::2]))")'
    ) @=> ret[x];
  }
  return ret;
}


fun static $1 make(`shift($@)')
)
')
