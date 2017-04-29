
include(pulses.m4)
include(midiPorts.m4)
include(aliases.m4)
include(macros.m4)


define(B, Runner.ticksPerBeat)
define(B2, B/2)
define(B4, B2/2)
define(B6, B+B2)
define(B8, B4/2)
define(B16, B8/2)
define(B32, B16/2)

dnl define(B3, B-B4)
dnl define(B5, B+B4)
dnl define(B7, B+B2+B4)
dnl define(B12, B8+B4)

define(Bar, (B*4))


define(octaves, ModuckP.make(Offset.make($1*12)))
define(output, ModuckP.make(NoteOut.make($2, $3, 0::ms, TIME_PER_BEAT/$4, $5)) @=> ModuckP $1;)

define(S, ModuckP.make(Sequencer.make($@)))
define(SQ, Sequencer)
define(def, ModuckP.make(

$2
).setName("$1 - `FILIN'") @=> ModuckP $1;)

define(defl,[
  `shift($@)'
]
@=> ModuckP $1[];

)

define(mkc, `mk($@)'.c)
define(mkcc, `mk($@)'.cc)

define(frm, ModuckP._from($1))
define(iff, ModuckP.make(Repeater.make())._iff($1, $2))


