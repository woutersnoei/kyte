(

(
SynthDef( "kyte_lowblow", { |amp = 0.5|
	var sig;
	
	sig = PrivateIn.ar( 0 );
	sig = Normalizer.ar( sig ) * amp;
	sig = DelayC.ar( sig, 8, 
		[ Line.kr(0,8,10), Line.kr(0,8,12), Line.kr(0,8,11), Line.kr(0,8,13) ]
	);
	Out.ar( 0, sig * Env([0,0,1,0],[0.19, 0.01, 9.8], -4).kr(2) );
}).load(s);
);


SynthDef( "kyte_dust10", { 
	arg lfoSpeed = 0.125, lowcut = #[20,10000], hicut = #[200,20000], range = 24, offset = 12,
		dens = 50, ringTime = 0.25, gate = 1, amp = 0.1;
	var sig, amps, n = 16;
	var ratios;
	var fftbuf;
	var env;
	//sig = PlayBuf.ar( 1, ~kyte.buf_mid, loop: 1);
	sig = PrivateIn.ar( 0 );
	
	fftbuf = LocalBuf( 2048, 1 ).clear;
	fftbuf = FFT( fftbuf, sig );
	2.do({
		fftbuf = PV_MagSquared( fftbuf );
	});
	sig = IFFT( fftbuf ) / 2;
	
	sig = Normalizer.ar( sig ) * 0.5 *  Line.kr(0,1,1);
	//amps = LFDNoise3.kr(0.25.dup(n)).exprange(-40.dbamp,1);
	amps = n * 1;
	amps = amps * Dust.kr((dens/n).dup(n)).lag(0,ringTime).squared;
	range = range.lag(0.1); offset = offset.lag(0.1);
	ratios = (..n-1).linlin(0,n-1,range.neg + offset,range + offset).midiratio;
	
	sig = BLowCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *lowcut.lag(1) ).clip(20,20000), 4 );
	sig = BHiCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *hicut.lag(1) ).clip(20,20000), 4 );

	sig = PitchShift.ar( sig, 0.2, ratios, 0.01, 0.2 );
	sig = sig * amps;
	sig = DelayC.ar( sig, 3, 
		Line.kr(-0.5,0.5pi,10).sin.linlin(-1,1,0,1) * LFDNoise3.kr(0.125.dup(n)).range(0,3) );
	sig = sig.collect({ |sig|
		RoundPan.ar(4, sig, LFDNoise3.kr(0.125) );
	});
	
	env = Env.asr(0.5,1,0.5).kr(2, gate);
	
	PrivateOut.ar( 2, 
		(sig.collect({ |item| item * LFDNoise3.kr(0.1).range(0,1) }).sum /n) * amp * 0.25 * env );
		
	Out.ar( 0, env * amp * sig.sum / n );
	
}).load(s);


SynthDef( "kyte_combs12", { 
	arg lfoSpeed = 0.125, lowcut = #[20,10000], hicut = #[200,20000], range = 12, offset = -8,
		speed = 0.5, ringTime = 5, shiftSpeed = 0.01, gate = 1, amp = 0.25, nn = 6;
	var sig, amps, n = 12;
	var ratios;
	var fftbuf;
	var env;
	//sig = PlayBuf.ar( 1, ~kyte.buf_mid, loop: 1);
	sig = PrivateIn.ar(0);
	
	fftbuf = LocalBuf( 2048, 1 ).clear;
	fftbuf = FFT( fftbuf, sig );
	1.do({
		fftbuf = PV_MagSquared( fftbuf );
	});
	sig = IFFT( fftbuf ) / 2;
	
	
	sig = Normalizer.ar( sig ) * amp *  Line.kr(0,1,1);
	amps = LFDNoise3.kr(0.25.dup(n)).exprange(-60.dbamp,1);
	amps = amps / amps.sum * n;
	range = range.lag(0.1); offset = offset.lag(0.1);
	ratios = (..n-1).linlin(0,n-1,range.neg + offset,range + offset).midiratio;
	
	sig = BLowCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *lowcut.lag(1) ).clip(20,20000), 4 );
	sig = BHiCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *hicut.lag(1) ).clip(20,20000), 4 );
	sig = PitchShift.ar( sig, 0.2, ratios, 0.01, 0.2 );
	sig = Limiter.ar( 
		FreqShift.ar( 
			CombC.ar( sig, 1/10, { 1/ (10.0 rrand: 200) }!n, ringTime.lag(0.1)),
			 { LFDNoise3.kr( shiftSpeed ).range(-400,400) }!n
		), 0.5 
	);
	sig = DelayC.ar( sig, 3, 
		 LFDNoise3.kr({ 0.05 rrand: 0.1 }.dup(n) * speed).range(0,3) );
		 
	nn = nn.lag(4);
	sig = XFadeRotate.ar( LFSaw.kr(0.1/n).range(0,n),  sig ) * 
		({ |i| nn.linlin(i,i+1,0,1,\minmax) }!n);
		 
	sig = sig.collect({ |sig|
		RoundPan.ar(4, sig, LFDNoise3.kr(0.05) );
	});
		 
	
	env =  Env.asr(0.5,1,0.5).kr(2, gate);
	//sig.postln;
	PrivateOut.ar( 2, env * sig.sum * 0.05 );
	Out.ar( 0, env * ( sig * amps ).sum * 0.125);	
}).load(s);


SynthDef( "kyte_frogs_15", { 
	arg lfoSpeed = 0.125, lowcut = #[20,10000], hicut = #[200,20000], range = 16, offset = 0, 
		gate = 1, amp = 0.25, nn = 15;
	var sig, amps, n = 15;
	var ratios;
	var fftbuf;
	var pos;
	var dbuf;
	var env;
	//sig = PlayBuf.ar( 1, ~kyte.buf_mid, loop: 1);
	sig = PrivateIn.ar(0);
	
	dbuf = LocalBuf((2.8 * 44100).nextPowerOfTwo,1).clear; 
	
	/*
	fftbuf = LocalBuf( 2048, 1 ).clear;
	fftbuf = FFT( fftbuf, sig );
	1.do({
		fftbuf = PV_MagSquared( fftbuf );
	});
	sig = IFFT( fftbuf ) / 2;
	*/
	
	sig = Normalizer.ar( sig ) * amp*  Line.kr(0,1,1);
	amps = LFDNoise3.kr(0.25.dup(n)).exprange(-60.dbamp,1);
	
	amps = amps / amps.sum * n;
	range = range.lag(0.1); offset = offset.lag(0.1);
	ratios = (..n-1).linlin(0,n-1,range.neg + offset,range + offset).midiratio;
	
	sig = BLowCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *lowcut.lag(1) ).clip(20,20000), 4 );
	sig = BHiCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *hicut.lag(1) ).clip(20,20000), 4 );
	sig = PitchShift.ar( sig, 0.2, ratios, 0.01, 0.2 );
	sig = DelayC.ar(  sig, 3, 
		Line.kr(-0.5,0.5pi,10).sin.linlin(-1,1,0,1) * LFDNoise3.kr(0.125.dup(n)).range(0,2.8) );
	sig = sig * SinOsc.kr( LFDNoise3.kr( 0.05.dup(n) ).exprange(10,40) )
				.blend(1, LFDNoise3.kr(0.05).range(0,1) ) * Trig.kr( 
					TIRand.kr( 0, 1, Impulse.kr( LFDNoise3.kr(0.05.dup(n)).exprange(5,25) ) ), 
		LFDNoise3.kr( 0.1 ).exprange(0.05, 0.125 )
	);
	
	pos = LFDNoise3.kr(0.125.dup(n));
	
	nn = nn.lag(4);
	sig = XFadeRotate.ar( LFSaw.kr(0.1/n).range(0,n),  sig ) * 
		({ |i| nn.linlin(i,i+1,0,1,\minmax) }!n);

	sig = sig.collect({ |sig,i|
		RoundPan.ar(4, sig, pos[i] );
	});
	
	env = Env.asr(0.5,1,0.5).kr(2, gate);
	
	sig = sig * env;
	
	//sig.postln;
	PrivateOut.ar(2, sig.sum * env * 0.125 );
	
	//Splay.ar( sig * amps * 1);	
	Out.ar( 0, (sig * amps).sum * env * 0.5 );
	
}).load(s);

SynthDef( "kyte_frogs_5", { 
	arg lfoSpeed = 0.125, lowcut = #[20,10000], hicut = #[200,20000], range = 16, offset = 0, 
		gate = 1, amp = 0.25, nn = 5;
	var sig, amps, n = 5;
	var ratios;
	var fftbuf;
	var pos;
	var dbuf;
	//sig = PlayBuf.ar( 1, ~kyte.buf_mid, loop: 1);
	sig = PrivateIn.ar(0);
	
	dbuf = LocalBuf((2.8 * 44100).nextPowerOfTwo,1).clear; 
	
	/*
	fftbuf = LocalBuf( 2048, 1 ).clear;
	fftbuf = FFT( fftbuf, sig );
	1.do({
		fftbuf = PV_MagSquared( fftbuf );
	});
	sig = IFFT( fftbuf ) / 2;
	*/
	
	sig = Normalizer.ar( sig ) * amp *  Line.kr(0,1,1);
	amps = LFDNoise3.kr(0.25.dup(n)).exprange(-60.dbamp,1);
	
	amps = amps / amps.sum * n;
	range = range.lag(0.1); offset = offset.lag(0.1);
	ratios = (..n-1).linlin(0,n-1,range.neg + offset,range + offset).midiratio;
	
	sig = BLowCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *lowcut.lag(1) ).clip(20,20000), 4 );
	sig = BHiCut.ar( sig, LFDNoise3.kr(lfoSpeed.dup(n)).exprange( *hicut.lag(1) ).clip(20,20000), 4 );
	sig = PitchShift.ar( sig, 0.2, ratios, 0.01, 0.2 );
	sig = DelayC.ar(  sig, 3, 
		Line.kr(-0.5,0.5pi,10).sin.linlin(-1,1,0,1) * LFDNoise3.kr(0.125.dup(n)).range(0,2.8) );
	sig = sig * SinOsc.kr( LFDNoise3.kr( 0.05.dup(n) ).exprange(10,40) )
				.blend(1, LFDNoise3.kr(0.05).range(0,1) ) * Trig.kr( 
					TIRand.kr( 0, 1, Impulse.kr( LFDNoise3.kr(0.05.dup(n)).exprange(5,25) ) ), 
		LFDNoise3.kr( 0.1 ).exprange(0.05, 0.125 )
	);
	
	pos = LFDNoise3.kr(0.125.dup(n));
	
	nn = nn.lag(4);
	sig = XFadeRotate.ar( LFSaw.kr(0.1/n).range(0,n),  sig ) * 
		({ |i| nn.linlin(i,i+1,0,1,\minmax) }!n);

	sig = sig.collect({ |sig,i|
		RoundPan.ar(4, sig, pos[i] );
	});
	
	//sig.postln;
	PrivateOut.ar(2, sig.sum * 0.125 );
	
	//Splay.ar( sig * amps * 1);	
	Out.ar( 0, Env.asr(0.5,1,0.5).kr(2, gate) * (sig * amps).sum * 0.5 );
	
}).load(s);

SynthDef( "kyte_metally", { |amp = 0.5, level = 0, lowcut = #[500,3000], hicut = #[2000,5000],
		range = #[500,5000], ring = #[0.05,0.2], lag = 0.05, leak = 0.99, lfoSpeed = 0.05, 
		gate = 1 |
	var sig, env, delayed;
	sig = GrayNoise.ar(1);
	sig = BLowCut.ar(sig, LFDNoise3.kr(lfoSpeed).exprange(*lowcut).clip(20,20000), 3 );
	sig = BHiCut.ar(sig, LFDNoise3.kr(lfoSpeed).exprange(*hicut).clip(20,20000), 3 );
	sig = Klank.ar(`[ 
		SortedRand.ir( 10, range[0], range[1], \exp).clip(20,20000), 
		ExpRand(0.1,1), 
		SortedRand.ir( 10, ring[0], ring[1], \exp ).clip(0.0001,1)
	], sig ) * 0.1;
	level = LPFLag.kr( 
		LeakDC.kr( level * Line.kr(0,1,0.25), 0.99 ).max(0), 
		lag.lag(2) 
	);
	level = (level / Amplitude.kr( level, 0, 1 ).max(0.005)).clip(0,1) * Line.kr(-1,1,1).max(0);
	sig = sig * level;
	env = Env.asr(2,1,4).kr(2,gate);
	sig = sig * env * amp.lag(1);
	
	delayed = DelayC.ar( sig, 0.75, LFDNoise3.kr(0.2).range(0,0.75) );
	delayed = FreqShift.ar( delayed, LFDNoise3.kr(lfoSpeed).range(-400,400) ) * 0.25;
	
	PrivateOut.ar( 2, (sig + delayed).dup(4) * 0.05 );
	sig = RoundPan.ar(4, sig, LFDNoise3.kr(0.05) ) + RoundPan.ar(4, delayed, LFDNoise3.kr(0.05) );
	
	Out.ar(0, sig ); 
}).load(s);

SynthDef( "kyte_spread", { |from = #[400, 1000], modSpeed = 0.1, ringTime = 10, ampSpeed = 1, 
		amp = 0.25, gate = 1, freqSpeed = 0.05, to = #[50,10000], dev = 0.005, bw = 0.001|
	var sig, amps, n = 40, range = 10, offset = 0;
	var ratios, freqs, sigx, siglim;
	var env, noise;
	
	//sig = PlayBuf.ar( 1, ~kyte.buf_mid, 1, loop: 1);
	//sig = BLowCut.ar( sig, 450, 5 );
	//sig = BHiCut.ar( sig, 800, 5 );
	sig = PrivateIn.ar(0);
	
	//freqs = n.collect({ |i| i.linlin(0,n-1,450,800) });
	
	freqs = n.collect({ LFDNoise3.kr(freqSpeed).range(0.125,1.875) }).integrate;
	freqs = freqs - freqs[0];
	freqs = freqs / freqs.last;
	freqs = freqs.linexp(0,1, *from);
	
	noise = PinkNoise.ar(0.5.dup(4));
	
	to = to.lag(5);
	modSpeed = modSpeed.lag(4);
	
	siglim = BLowCut.ar( sig, from[0], 3 );
	siglim = BHiCut.ar( siglim, from[1], 3 );
	
	#sigx, amps = n.collect({ |i|
		var sg, amp;
		sg = Ringz.ar( siglim, freqs[i], [1,0.5] * ringTime, [0.1,-0.1]);		amp = Amplitude.kr( sg[1], (ringTime * ampSpeed) / 2, ringTime * ampSpeed );
		sg = sg.sum + BBandPass.ar( noise.wrapAt(i), freqs[i], bw.lag(1) );
		sg = FreqShift.ar(sg, freqs[i].expexp(from[0],from[1], to[0],to[1]+from[0]) - from[0] );
		//sg = SinOsc.ar( i.linlin(0,n-1,50,3000), 2pi.rand, 0.1 );
		[sg, amp];
	}).flop;
	
	amps = amps.pow(2);
	amps = amps / amps.sum.max(0.001);
	
	amps = amps * SinOsc.kr(
		LFDNoise3.kr(0.01.dup(n)).exprange(0.05,5) * modSpeed
	).range(0,1).pow(4);
	
	sigx = SplayAz.ar( 4, sigx * amps, center: LFSaw.kr( LFDNoise1.kr(0.1) * 0.1 ) );
		
	sig = Line.ar( -1,1,0.8).max(0) * Normalizer.ar(sigx, dur: 0.2) * 0.25 * amp;
	
	sig = PitchShift.ar( sig, 0.1, 1, dev, 0.01 );
	
	env = Env.asr(2,1,2).kr(2,gate);
	
	PrivateOut.ar(2,sig * env * 0.5);
	Out.ar( 0, sig * env );	
}).load(s);

);
