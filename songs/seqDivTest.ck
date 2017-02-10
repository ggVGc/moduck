
30 => BPM;
4 => TICKS_PER_BEAT;

def(d, seqDiv([4, 2, 1, 1, 2]))

C2(d, Pulse.Looped(), Printer.make("looped"), null);

C(d, Printer.make("Out"));

C(masterClock, Printer.make("TICK"));
C(masterClock, d);

