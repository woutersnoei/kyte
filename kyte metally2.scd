(
~kyte = ~kyte ? EM();

~kyte.metally = ~kyte.metally ? EM();

~kyte.metally.synths = Order();

~kyte.metally.dataPoll = { |evt, mul = 1|
	evt.synths.do({ |synth, i|
		 synth.set( \level, ~kyte.dataPoll(i) * (i/100) );
	});
};

~kyte.metally.updateRate = 40;

~kyte.metally.startTask = { |evt|
	evt.task.stop;
	evt.task = {
		100.do({ |i|
			evt.dataPoll( i/100 );
			(1/(evt.updateRate ? 50)).wait;
		});
		"~kyte metally task fadein done".postln;
		loop {
			evt.dataPoll;
			(1/(evt.updateRate ? 50)).wait;
		};
	}.fork;
};

~kyte.metally.endTask = { |evt|
	evt.task.stop;
	evt.task = nil;
};

~kyte.metally.start = { |evt, index = #[2,3]|
	if( evt.task.isNil or: { evt.task.isPlaying.not }) {
		evt.startTask;
	};
	evt.arm;
	evt.end( index );
	index.asCollection.do({ |id|
		evt.synths[ id ] = Synth( "kyte_metally",  evt.settings.getPairs );
	});
};

~kyte.metally.end = { |evt, index|
	if( index.isNil ) {
		evt.synths.do(_.release);
		evt.synths = Order();
	} {
		index.asCollection.do({ |id|
			evt.synths[id].release;
			evt.synths[id] = nil;
		});
	};
};

~kyte.metally.settings = OEM();
~kyte.metally.specs = OEM();

[ 
	'amp', [ 0.5, \amp.asSpec ],
	'lfoSpeed', [ 0.05, [0.01,1,\exp] ],  
	'lowcut', [ [ 500, 3000 ], \freq.asSpec ], 
	'hicut', [ [ 2000, 5000 ], \freq.asSpec ], 
	'range', [ [ 500, 5000 ], \freq.asSpec ],
	'ring', [ [ 0.05, 0.2 ], [0.01,1,\exp].asSpec ],
	'lag', [ 0.05, [0.01,0.5, \exp].asSpec ], 
	'leak', [ 0.99, [0.5,0.9999, -8].asSpec ], 
].pairsDo({ |key, value|
	~kyte.metally.settings[ key ] = value[0];
	~kyte.metally.specs[ key ] = value[1].asSpec;
});

~kyte.metally.arm = { |evt|
	evt.settings.removeDependant( evt[ \updateFunc ] );
	evt[ \updateFunc ] = { evt.synths.do(_.set( *evt.settings.getPairs )); };
	evt.settings.addDependant( evt[ \updateFunc ] );
};

)

/*


~kyte.metally.start( 1 );

~kyte.metally.start( 2 );

~kyte.metally.start( 3 );

~kyte.metally.start( 4 );

~kyte.metally.synths[4].set( \lag, 0.4 );
~kyte.metally.synths[4].set( \leak, 0.999 );


~kyte.lowblow;
~kyte.metally.end;
~kyte.combs.start;

~kyte.metally.settings.amp = 0.25;

~kyte.metally.settings.leak




*/





