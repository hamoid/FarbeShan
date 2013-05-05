// Farbe_Shan - SuperCollider code
// https://github.com/hamoid/FarbeShan

// Works together with the FarbeShan Processing code
// to generate sound based on curves the user draws
// on top of a playing video.

// This is currently a proof of concept and has not yet
// been tweaked to be good for live performing or produce
// good sounds. It should be modified to make sounds be
// more unique depending on hue or brightness.

// the url should be the one of computer of app 2 (or nil)
n = NetAddr("127.0.0.1", NetAddr.langPort);

(
// hue, sat, bri and alpha are scaled down
o = OSCresponder(nil, '/FS', { |t, r, msg|
    Synth("FarbeShan", [
        \id, msg[1],
        \hue, msg[2].linlin(0, 255, 0.0, 1.0),
        \sat, msg[3].linlin(0, 255, 0.0, 1.0),
        \bri, msg[4].linlin(0, 255, 0.0, 1.0),
        \alpha, msg[5].linlin(0, 255, 0.0, 1.0)
    ]);
}).add;
)
o.free;

(
// Test sound that accepts all parameters coming from Processing
// id currently unused. It indicates the curve id, which can be
// between 0 and MAX_CURVES, and can be used to play different sounds
// depending on id.
SynthDef("FarbeShan", { | out=0, id=0, hue=0, sat=0, bri=0, alpha=0|
    var frq;
    // The pitch depends on the hue
    frq = (50 + (hue * 48)).floor.midicps;
    Out.ar(out,
         SinOsc.ar(
            // Saturation increases pitch offset between left and right speaker
            frq + [sat * 5, sat * -5],
            // Brightness and alpha both control the volume
            // Alpha goes down when particles disappear at the end of the curve life
            mul:bri * alpha * Linen.kr(Impulse.kr(0), 0.05, 0.1, 1.1, doneAction:2)))
}).add;
)

// Play the test sound
Synth("FarbeShan", [\hue, 0.5, \alpha, 1, \bri, 0.5]);


// Other available synths
(
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
