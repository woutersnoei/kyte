~kyte.getPreset = { |evt, which|
	evt[ which ].settings.copy;
};

~kyte.applyPreset = { |evt, which, preset|
	preset.keysValuesDo({ |key, value|
		if( evt[ which ].settings.keys.includes( key ) ) {
			evt[ which ].settings[ key ] = value;
		};
	});
};

~kyte.blendApplyPreset = { |evt, which, preset1, preset2, amt = 0.5|
	preset1.keysValuesDo({ |key, value|
		var spec;
		if( evt[ which ].settings.keys.includes( key ) ) {
			spec = evt[ which ].specs[ key ];
			value = spec.unmap( value ).blend( spec.unmap( preset2[ key ] ), amt );
			evt[ which ].settings[ key ] = spec.map( value );
		};
	});
};

~kyte.states = OEM();

~kyte.getState = { |evt, name = \default|
	evt.states[ name ] = ();
	[ \dust, \combs, \frogs, \metally, \spread ].do({ |item|
		evt.states[ name ][ item ] = evt.getPreset( item );
	});
};

~kyte.applyState = { |evt, name = \default, time = 0|
	var state;
	state = evt.states[ name ];
	if( state.notNil ) {
		if( time == 0 ) {
			state.keysValuesDo({ |key, value|
				evt.applyPreset( key, value );
			});
		} {
			{
				var current;
				current = ();
				state.keysValuesDo({ |key, value|
					current[ key ] = evt.getPreset( key );
				});
				((time * 10) + 1).do({ |i|
					state.keysValuesDo({ |key, value|
						evt.blendApplyPreset( key, current[ key ], value, i/(time*10));
					});
					(1/10).wait;
				});
			}.fork;
		};
	};
};



/*
x = ~kyte.getPreset( \combs );

y = ~kyte.getPreset( \combs );

~kyte.applyPreset( \combs, x );
~kyte.applyPreset( \combs, y );

~kyte.getState( \default );

~kyte.getState( \next );


~kyte.states.cs

~kyte.getState( \next );

~kyte.applyState( \next, 10 );

~kyte.applyState( \default, 10);

(
{
	var current;
	current = ~kyte.getPreset( \combs );
	20.do({ |i|
		~kyte.blendApplyPreset( \combs, current, x, i/19);
		(1/20).wait;
	});
}.fork;
)
*/
