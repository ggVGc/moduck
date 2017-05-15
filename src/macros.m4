
include(pulses.m4)

ifdef(`MACROS_INCLUDED',,`define(MACROS_INCLUDED,1)dnl

define(BOOL, int)
define(TRUE, 1)
define(FALSE, 0)

define(FILIN,`__file__':`__line__')

define(FAIL_TEST,if(!$1){<<< "$1 failed - `FILIN'" >>>;$2}else{$3})

define(fori, for(0=>int $1; $1<$2; $1++){$3})

define(WARNING,
    <<< "Warning: "+$1+" - `FILIN'" >>>;)


define(ASSERT,
    if(!($1)){<<<"Assertion Failure: $1 -- `FILIN'">>>;})


')
