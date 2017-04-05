
include(song_macros.m4);

def(tog, mk(Toggler));


tog
  => MBUtil.onlyHigh().c
  => mk(Printer, "out").c;

tog => mk(Printer, "active").from(P_Active).c;

10::ms => now;
<<<"Banging">>>;
tog.bang();
10::ms => now;
<<<"Toggling">>>;
tog.doHandle(P_Toggle, IntRef.make(0));
10::ms => now;
<<<"Banging">>>;
tog.bang();
10::ms => now;
<<<"Toggling">>>;
tog.doHandle(P_Toggle, IntRef.make(0));
10::ms => now;
<<<"Banging">>>;
tog.bang();





