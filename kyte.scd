(
~kyte = ~kyte ? EM();

~kyte.path = thisProcess.nowExecutingPath.dirname;

~kyte.buf_mid = Buffer.read( s, ~kyte.path +/+ "kyte-loop-mid2.aif" );

~kyte.ir = InputRouter.unique(s, \kyte, [ \kyte ] );
~kyte.ir.gui;


// ~kyte.froukeIP = "192.168.2.8"; // enable dataNetwork reception
~kyte.froukeIP = nil;

//~kyte.ir.start;

/*
~kyte.playKyte;

~kyte.stopKyte;
*/

~kyte.fileNames = [
	"dataNetwork",
	"elements",
	"metally2",
	"verb",
	"synthdefs",
	"gui"
].collect({ |item| ~kyte.path +/+ "kyte" + item ++ ".scd" });

~kyte.fileNames.do(_.load);

~kyte.fileWindow !? _.close;

~kyte.fileWindow = Window( "kyte files", 
		Rect( 9, 366, 130, (~kyte.fileNames.size * 20) + 4 ) 
).front;

~kyte.fileWindow.addFlowLayout;

~kyte.fileNames.do({ |item|
	RoundButton( ~kyte.fileWindow, 122 @ 16 )
		.label_( item.basename )
		.action_({ Document.open( item ) });
});

~kyte.playKyte = { |evt|
	evt.kyteSynth.free;
	evt.kyteSynth = {
		PrivateOut.ar( 0, PlayBuf.ar( 1,evt.buf_mid, loop: 1) );
		//PrivateOut.ar( 0, SinOsc.ar(440,0,0.1) );
	}.play( addAction: \addBefore );
};

~kyte.stopKyte = { |evt|
	evt.kyteSynth.free;
	evt.kyteSynth = nil;
};


~kyte.cmdPeriod = { |evt|
	if( evt.kyteSynth.notNil ) {
		{ evt.playKyte; }.defer(0.1);
	};
};

CmdPeriod.add( ~kyte );
)
/*
~kyte.playKyte;

~kyte.stopKyte;
*/