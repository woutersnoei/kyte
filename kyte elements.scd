(
~kyte = ~kyte ? EM();

~kyte.dust = ~kyte.dust ? EM();

~kyte.dust.settings = ~kyte.dust.settings ? OEM();
~kyte.dust.specs = ~kyte.dust.specs ? EM();

[
	\amp, [ 0.25, \amp.asSpec ],
	\lfoSpeed, [ 0.125, [0.05,1,\exp] ], 
	\lowcut, [ [20,10000],  \freq ],
	\hicut, [ [200,20000], \freq ],
	\range, [ 24, [0,36,\lin,1] ],
	\offset, [ 12, [-24,24,\lin,1] ],
].pairsDo({ |key, value|
	~kyte.dust.settings[ key ] = value[0];
	~kyte.dust.specs[ key ] = value[1].asSpec;
});

~kyte.dust.arm = { |evt|
	evt.settings.removeDependant( evt[ \updateFunc ] );
	evt[ \updateFunc ] = { evt.sn.set( *evt.settings.getPairs ); };
	evt.settings.addDependant( evt[ \updateFunc ] );
};

~kyte.dust.start = { |evt|
	evt.arm;
	evt.end;
	evt.sn = Synth( evt.defName, evt.settings.getPairs );
};

~kyte.dust.end = { |evt|
	evt.sn !? _.release(2);
	evt.sn = nil;
};


/// frogs
~kyte.frogs = ~kyte.dust.deepCopy;

~kyte.frogs.defName = "kyte_frogs_15";

~kyte.frogs.settings.amp = 0.25;
~kyte.frogs.settings.range = 24;
~kyte.frogs.settings.offset = 12;
~kyte.frogs.settings.nn = 15;

~kyte.frogs.specs.nn = [1,15,\lin,1,1].asSpec;


// combs
~kyte.combs = ~kyte.dust.deepCopy;

~kyte.combs.defName = "kyte_combs12";

~kyte.combs.settings.amp = 0.25;
~kyte.combs.settings.range = 24;
~kyte.combs.settings.offset = 0;

~kyte.combs.settings.speed = 0.5; 
~kyte.combs.settings.ringTime = 5;
~kyte.combs.settings.shiftSpeed = 0.01;
~kyte.combs.settings.nn = 12;

~kyte.combs.specs.speed = [0.1,20,\exp].asSpec; 
~kyte.combs.specs.ringTime = [0.1,10,\exp].asSpec;
~kyte.combs.specs.shiftSpeed = [0.001,1,\exp].asSpec;
~kyte.combs.specs.nn = [1,12,\lin,1,1].asSpec;



// dust
~kyte.dust.defName = "kyte_dust10";

~kyte.dust.settings.amp = 0.5;
~kyte.dust.settings.range = 12;
~kyte.dust.settings.offset=  24;

~kyte.dust.settings.dens = 20;
~kyte.dust.settings.ringTime = 0.24;

~kyte.dust.specs.dens= [0,100,\lin,1].asSpec; 
~kyte.dust.specs.ringTime = [0.1,10,\exp].asSpec;


// lowblow
~kyte.lowblow = { |evt|
	Synth( "kyte_lowblow" );
};


)
/*
~kyte.dust.start;

~kyte.combs.start;

~kyte.frogs.start;

~kyte.lowblow;

(
~kyte.dust.end;
~kyte.combs.end;
~kyte.frogs.end;
)

~kyte.dust.settings

.ringTime = nil;


*/