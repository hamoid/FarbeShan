
n = NetAddr("127.0.0.1", NetAddr.langPort); // the url should be the one of computer of app 2 (or nil)
n = NetAddr("127.0.0.1", 57120); // the url should be the one of computer of app 2 (or nil)

101%5


(
o = OSCresponder(nil, '/FS', { |t, r, msg|
	var h, s, b, line;
	//msg.postln;
	~id = msg[1]%4;
	~hue = msg[2];
	~sat = msg[3];
	~bri = msg[4];
	~decayOrg = msg[5];
	~decay = ~decayOrg.linlin(0,255,0.0,1.0);

	x = case
	{~id == 0} {
		//"val 0".postln;
		if(~hue > 0, {~s0 = Synth("don", [\freq, ~hue.linlin(0,255,30,42).midicps, \amp, ~decay]);});
	}
	{~id == 1} {
		//"val 1".postln;
		if(~hue > 50, {~s1 = Synth("highh", [\pitch, ~hue.linlin(50,255,0.6,0.8), \amp, ~decay]);});
	}

	{~id == 2} {
		//"val 2".postln;
		if(~hue > 0, {~s2 = Synth("telep", [\a, ~hue.linlin(0,255,800,1000), \amp, ~decay])});
	}
	{~id == 3} {
		//"val 3".postln;
		if(~hue > 50, {~s3 = Synth("playBuf", [\rate, ~hue.linlin(50,255,0.8,1.4).round(0.1), \amp, ~decay])});
	}
	{~id == 4} {
		//"val 4".postln;
	}
	{~id == 5} {
		//"val 5".postln;
	}
	{~id == 6} {
		//"val 6".postln;
	}
	{~id == 7} {
		//"val 7".postln;
	};



}).add;
)

o.free;

(
~f1 = Buffer.read(s, "/Users/LL/Music/sounds/1/cSharp1.wav", bufnum:11);
//
SynthDef("klankie", { |pitch=1, amp=1|  var source, kl ;
	kl=[800, 1071, 1153, 2023] ;
	source = Klank.ar(`[(kl*1.5), 0.3, [0.5, 1, 2, 0.5]*0.3],
		SinOsc.ar(pitch*400, mul: XLine.ar(0.35, 0.000001, 2)));
	Out.ar([0,1], source*amp);
	DetectSilence.ar(source, doneAction:2);
}).add;

SynthDef("telep", { | out=0, a=1000, amp=0|
			var source;
			source = LFPulse.ar(7, mul:200, add: a)*amp;
			Out.ar(out, SinOsc.ar(source, mul:XLine.kr(0.1, 0.01, 0.5, doneAction:2))!2)
}).add;

SynthDef("don", { | freq= 150, amp=1, gate=1|
		Out.ar([0,1], SinOsc.ar(freq, mul:amp) *
		EnvGen.kr(Env.perc(0.01,0.5,1,-4), gate, doneAction: 2))
}).add;

SynthDef("highh", { | pitch=0.8 , amp=1|  var source, input1, input2;
	input1 = Klank.ar(`[[800, 1071, 1153, 1723]*1.2, nil, [1, 1, 1, 1]],
		SinOsc.ar(5200*pitch, mul: EnvGen.kr(Env.perc(0.001, 0.3, 0.0015, -3))))*amp;
	input2 = Resonz.ar(
		PinkNoise.ar(15)*EnvGen.kr(Env.perc(0.001, 0.7, 0.5, -3)) , 13000, 0.4, 0.05)*amp;
	source = AllpassN.ar([input2+input1], 0.8, [0.08.rand, 0.07.rand], 1);
	DetectSilence.ar(source, doneAction:2);
	Out.ar(0, [source, source]);
}).add;

SynthDef(\playBuf,{ |bufnum=11,lo=0, amp=0.9, rate=2|
	var env, out;
	env = EnvGen.kr(Env.perc(0.05, 0.6, 0.5, 1, curve:-4),doneAction:2);
	out = PlayBuf.ar(1, bufnum,  BufRateScale.kr(bufnum)*rate, loop:lo ) ; //* env;
	Out.ar(0, Limiter.ar(out*amp, 0.7, 0.01)!2);
	FreeSelfWhenDone.kr(out);
}).add;
)

(
~seq1 = Pseq([1,1.5,2,1,1],inf).asStream;

~s1 = Synth("klankie", [\pitch, 1]);
~s2 = Synth("telep", [\a, 900]);

)

//////Tdef///////
(
Tdef( 'klankT' , {
	var y = Pseq([1,1.5,2,1,1],inf).asStream;
	//var x = Prand([1,1,1,1.5,0.5,2,1],6).asStream;
	2.do { |i|
		(	'instrument': 'klankie',
			'pitch': ~hue/100,

		).play;
		0.16.wait;
	};
}).play;
)

1/6
38/255
Pdef