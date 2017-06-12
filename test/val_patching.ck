include(song_macros.m4);

Moduck m;
m.addVal("a", 2);
Printer.make("DIDD") @=> Printer p1;
Printer.make("HELLO") @=> Printer p2;


<<< Patch.connect(m, p1).findDefaultOutputTag() >>>;

samp =>  now;
m.setVal("a", 4);




/* 
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
 
 
 
 
 */
