
define(octaves, ModuckP.make(Offset.make($1*12)))
define(output, ModuckP.make(NoteOut.make($2, $3, 0::ms, TIME_PER_BEAT/$4, $5)) @=> ModuckP $1;)

dnl define(from, ModuckP.from)
dnl define(to, ModuckP.to)

define(S, ModuckP.make(Sequencer.make($@)))
define(SQ, Sequencer)
define(def, ModuckP.make(

$2
) @=> ModuckP $1;)


define(mkc, `mk($@)'.c)
define(mkcc, `mk($@)'.cc)
