
include(pulses.m4)

ifdef(`MACROS_INCLUDED',,`define(MACROS_INCLUDED,1)dnl


define(BOOL, int)
define(TRUE, 1)
define(FALSE, 0)

define(FILIN,`__file__':`__line__')

define(FAIL_TEST,if(!$1){<<< "$1 failed - `FILIN'" >>>;$2}else{$3})

define(fori, for(0=>int $1; $1<$2; $1++){$3})

define(WARNING,
    <<< "Warning: $1 - `FILIN'" >>>;)


define(ASSERT,
    if(!($1)){<<<"Assertion Failure: $1 -- `FILIN'">>>;})


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

    fun void add(Moduck parent){
      parent.addIn($2, this);
    }

    dnl fun void addDefault(Moduck parent){
    dnl   parent.addDefaultIn($2, this);
    dnl }

  }
)


define(IN, $1.make $2 .add(ret);)
define(OUT, ret.addOut($1);)

dnl define(IN_Default, $1.make $2 .addDefault(ret);)
dnl define(OUT_Default, ret.addDefaultOut($1);)


define(HANDLE, fun void handle(int v))







')

