(
~kyte = ~kyte ? EM();

~kyte.makeWindow = { |evt|
	
	if( evt.window.notNil && { evt.window.isClosed.not }) { evt.window.close };
	
	evt.window = Window("kyte", Rect(548, 453, 500, 600)).front;
	evt.window.addFlowLayout;
	evt.views =();
	
	RoundView.useWithSkin(( font: Font( Font.defaultSansFace, 9 ) ), {
		[ \dust, \combs, \frogs, \metally, \spread ].do({ |name|
			var evx, views, width, height, ctrl, ctrl2;
			evx = evt[ name ];
			views = ();
			width = ((evt.window.bounds.width/2) - 8);
			height = 14;
			
			views[ \comp ] = CompositeView( evt.window, 
				width @ (((evx.settings.size + 1) * (height + 2)) + 4) 
			).background_( Color.gray(0.9) );
			
			ctrl = SimpleController( evx.settings );
			ctrl2 = SimpleController( evx );
			
			views[ \comp ].addFlowLayout( 2@2,  2@2 );
			views[ \comp ].onClose_({ ctrl.remove; ctrl2.remove });
			
			width = width - 4;
			
			views[ \power ] = RoundButton( views[ \comp ], height @ height )
				.label_( [ 'power', 'power' ] )
				.hiliteColor_( Color.green )
				.border_( 1 )
				.value_( evx.sn.notNil.binaryValue )
				.action_({ |bt|
					switch( bt.value.asInt,
						1, { evx.start },
						0, { evx.end }
					);
				});
			
			StaticText( views[ \comp ], ((width - height) - 4) @ height )
				.string_( " " ++ name );
			
			evx.settings.keysValuesDo({ |key, value|
				var sliderClass = EZSmoothSlider;
				if( value.size == 2 ) { sliderClass = EZSmoothRanger };
				views[ key ] = sliderClass.new( 
					views[ \comp ], 
					width @ height,
					key,
					evx.specs[ key ],
					{ |sl| evx.settings[ key ] = sl.value },
					value
				);
				ctrl.put( key, { views[ key ].value = evx.settings[ key ]; });
			});
			
			ctrl2.put( \started, { views[ \power ].value = 1 });
			ctrl2.put( \ended, { views[ \power ].value = 0 });
			
			evt.views[ name ] = views;
		});
	})
};

~kyte.makeWindow
)