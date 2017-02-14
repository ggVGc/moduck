
define(octaves, Offset.make($1*12))
define(output, NoteOut.make($2, 0, 0::ms, TIME_PER_BEAT/$3) @=> NoteOut $1;)

define(S, Sequencer.make($@))
define(SQ, Sequencer)
define(def, $2 @=> Moduck $1;)
