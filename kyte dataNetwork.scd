(
~kyte = ~kyte ? EM();

// ~kyte.froukeIP = "192.168.2.8";
// ~kyte.froukeIP = nil;

~kyte.dataPath = thisProcess.nowExecutingPath.dirname +/+ "node_1.csv";

GUI.skin.plot.plotColor = 7.collect({ |i| Color.hsv(i/8, 1, 0.75 ) });

if( ~kyte.froukeIP.isNil ) {	
	~kyte.dataNetwork = SWDataNetwork.new;
	~kyte.dataNetwork.addExpected( 1 );
	
	// read it with the player:
	Tdef( \playData, { |ev|
		var deltatime, newdata, a;
		a = CSVFilePlayer.new( ~kyte.dataPath );
		newdata = a.nextInterpret.postcs;
		while ( {newdata.notNil} ){
			deltatime = newdata[0];
			~kyte.dataNetwork.setData( 1, newdata );
			a.nextInterpret; // empty line
			deltatime.wait;
			newdata = a.nextInterpret;
		};
		a.close;
	});
	
	TdefAllGui.new;
} {
	~kyte.dataNetwork = SWDataNetworkClient.new( ~kyte.froukeIP, "WoutersClient" );
};

~kyte.dataNetwork.makeGui;

~kyte.dataPointers = EM( \a, 0, \b, 1);

~kyte.dataPoll = { |evt, index = \a|
	if( evt.dataNetwork.nodes[1].notNil ) {
		evt.dataNetwork.nodes[1].slots[ evt.dataPointers[ index ] ? index ].value;
	} {
		nil;
	};
};

)