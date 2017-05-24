
include(pulses.m4)

ifdef(`MACROS_INCLUDED',,`define(MACROS_INCLUDED,1)dnl

define(BOOL, int)

define(FILIN,`__file__':`__line__')

define(FAIL_TEST,if(!$1){<<< "$1 failed - `FILIN'" >>>;$2}else{$3})

define(fori, for(0=>int $1; $1<$2; $1++){$3})

define(WARNING,
    <<< "Warning: "+$1+" - `FILIN'" >>>;)


define(assert,
    if(!($1)){<<<"Assertion Failure: $1 -- `FILIN'">>>;Machine.crash();})


define(allEquals,
    true => int $3;
    for(0=>int __ind;__ind<$1.size();++__ind){
      $1[__ind] @=> Object o;
      if(o != $2){
        false => $3;
        break;
      }
    }
  )


')
