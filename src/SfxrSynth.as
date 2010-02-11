package
{
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * SfxrSynth
	 * 
	 * Copyright 2009 Thomas Vian
	 *
	 * Licensed under the Apache License, Version 2.0 (the "License");
	 * you may not use this file except in compliance with the License.
	 * You may obtain a copy of the License at
	 *
	 * 	http://www.apache.org/licenses/LICENSE-2.0
	 *
	 * Unless required by applicable law or agreed to in writing, software
	 * distributed under the License is distributed on an "AS IS" BASIS,
	 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 * See the License for the specific language governing permissions and
	 * limitations under the License.
	 * 
	 * @author Thomas Vian
	 */
	public class SfxrSynth
	{
		//--------------------------------------------------------------------------
		//
		//  Sound Parameters
		//
		//--------------------------------------------------------------------------
		
		public var waveType				:uint = 	0;		// Shape of the wave (0:square, 1:saw, 2:sin or 3:noise)
		
		public var sampleRate			:uint = 	44100;	// Samples per second - only used for .wav export
		
		public var bitDepth				:uint = 	16;		// Bits per sample - only used for .wav export
		
		public var masterVolume			:Number = 	0.5;	// Overall volume of the sound (0 to 1)
		
		public var attackTime			:Number =	0.0;	// Length of the volume envelope attack (0 to 1)
		public var sustainTime			:Number = 	0.0;	// Length of the volume envelope sustain (0 to 1)
		public var sustainPunch			:Number = 	0.0;	// Tilts the sustain envelope for more 'pop' (0 to 1)
		public var decayTime			:Number = 	0.0;	// Length of the volume envelope decay (yes, I know it's called release) (0 to 1)
		
		public var startFrequency		:Number = 	0.0;	// Base note of the sound (0 to 1)
		public var minFrequency			:Number = 	0.0;	// If sliding, the sound will stop at this frequency, to prevent really low notes (0 to 1)
		
		public var slide				:Number = 	0.0;	// Slides the note up or down (-1 to 1)
		public var deltaSlide			:Number = 	0.0;	// Accelerates the slide (-1 to 1)
		
		public var vibratoDepth			:Number = 	0.0;	// Strength of the vibrato effect (0 to 1)
		public var vibratoSpeed			:Number = 	0.0;	// Speed of the vibrato effect (i.e. frequency) (0 to 1)
		
		public var changeAmount			:Number = 	0.0;	// Shift in note, either up or down (-1 to 1)
		public var changeSpeed			:Number = 	0.0;	// How fast the note shift happens (only happens once) (0 to 1)
		
		public var squareDuty			:Number = 	0.0;	// Controls the ratio between the up and down states of the square wave, changing the tibre (0 to 1)
		public var dutySweep			:Number = 	0.0;	// Sweeps the duty up or down (-1 to 1)
		
		public var repeatSpeed			:Number = 	0.0;	// Speed of the note repeating - certain variables are reset each time (0 to 1)
		
		public var phaserOffset			:Number = 	0.0;	// Offsets a second copy of the wave by a small phase, changing the tibre (-1 to 1)
		public var phaserSweep			:Number = 	0.0;	// Sweeps the phase up or down (-1 to 1)
		
		public var lpFilterCutoff		:Number = 	0.0;	// Frequency at which the low-pass filter starts attenuating higher frequencies (0 to 1)
		public var lpFilterCutoffSweep	:Number = 	0.0;	// Sweeps the low-pass cutoff up or down (-1 to 1)
		public var lpFilterResonance	:Number = 	0.0;	// Changes the attenuation rate for the low-pass filter, changing the timbre (0 to 1)
		
		public var hpFilterCutoff		:Number = 	0.0;	// Frequency at which the high-pass filter starts attenuating lower frequencies (0 to 1)
		public var hpFilterCutoffSweep	:Number = 	0.0;	// Sweeps the high-pass cutoff up or down (-1 to 1)
		
		//--------------------------------------------------------------------------
		//
		//  Sound Variables
		//
		//--------------------------------------------------------------------------
		
		private var _sound:Sound;							// Sound instance used to play the sound
		private var _channel:SoundChannel;					// SoundChannel instance of playing Sound
		
		private var _cachedWave:ByteArray;					// Cached wave data from a cacheSound() call
		private var _cachedMutations:Vector.<ByteArray>;	// Cached mutated wave data from a cacheMutations() call
		private var _cachedMutationsNum:uint;				// Number of cached mutations
		
		private var _waveData:ByteArray;					// Full wave, read out in chuncks by the onSampleData method
		private var _waveDataPos:uint;						// Current position in the waveData
		private var _waveDataLength:uint;					// Number of bytes in the waveData
		private var _waveDataBytes:uint;					// Number of bytes to write to the soundcard
		
		private var _original:SfxrSynth;					// Copied properties for mutationBase
		
		//--------------------------------------------------------------------------
		//
		//  Synth Variables
		//
		//--------------------------------------------------------------------------
		
		private var _envelopeVolume:Number;					// Current volume of the envelope
		private var _envelopeStage:int;						// Current stage of the envelope (attack, sustain, decay, end)
		private var _envelopeTime:Number;					// Current time through current enelope stage
		private var _envelopeLength:Number;					// Length of the current envelope stage
		private var _envelopeLength0:Number;				// Length of the attack stage
		private var _envelopeLength1:Number;				// Length of the sustain stage
		private var _envelopeLength2:Number;				// Length of the decay stage
		private var _envelopeOverLength0:Number;			// 1 / _envelopeLength0 (for quick calculations)
		private var _envelopeOverLength1:Number;			// 1 / _envelopeLength1 (for quick calculations)
		private var _envelopeOverLength2:Number;			// 1 / _envelopeLength2 (for quick calculations)
		private var _envelopeFullLength:Number;				// Full length of the volume envelop (and therefore sound)
		
		private var _phase:int;								// Phase through the wave
		private var _pos:Number;							// Phase expresed as a Number from 0-1
		private var _period:Number;							// Period of the wave
		private var _periodTemp:Number;						// Period modified by vibrato
		private var _maxPeriod:Number;						// Maximum period before sound stops (from minFrequency)
		
		private var _slide:Number;							// Note slide
		private var _deltaSlide:Number;						// Change in slide
		
		private var _vibratoPhase:Number;					// Phase through the vibrato sine wave
		private var _vibratoSpeed:Number;					// Speed at which the vibrato phase moves
		private var _vibratoAmplitude:Number;				// Amount to change the period of the wave by at the peak of the vibrato wave
		
		private var _changeAmount:Number					// Amount to change the note by
		private var _changeTime:int;						// Counter for the note change
		private var _changeLimit:int;						// Once the time reaches this limit, the note changes
		
		private var _squareDuty:Number;						// Offset of center switching point in the square wave
		private var _dutySweep:Number;						// Amount to change the duty by
		
		private var _repeatTime:int;						// Counter for the repeats
		private var _repeatLimit:int;						// Once the time reaches this limit, some of the variables are reset
		
		private var _phaserOffset:Number;					// Phase offset for phaser effect
		private var _phaserDeltaOffset:Number;				// Change in phase offset
		private var _phaserInt:int;							// Integer phaser offset, for bit maths
		private var _phaserPos:int;							// Position through the phaser buffer
		private var _phaserBuffer:Vector.<Number>;			// Buffer of wave values used to create the out of phase second wave
		
		private var _lpFilterPos:Number;					// Confession time
		private var _lpFilterOldPos:Number;					// I can't quite get a handle on how the filters work
		private var _lpFilterDeltaPos:Number;				// And the variables in the original source had short, meaningless names
		private var _lpFilterCutoff:Number;					// Perhaps someone would be kind enough to enlighten me
		private var _lpFilterDeltaCutoff:Number;			// I keep going back and staring at the code
		private var _lpFilterDamping:Number;				// But nothing comes to mind
		
		private var _hpFilterPos:Number;					// Oh well, it works
		private var _hpFilterCutoff:Number;					// And I guess that's all that matters
		private var _hpFilterDeltaCutoff:Number;			// Annoying though
		
		private var _noiseBuffer:Vector.<Number>;			// Buffer of random values used to generate noise
		
		private var _superSample:Number;					// Actual sample writen to the wave
		private var _sample:Number;							// Sub-sample calculated 8 times per actual sample, averaged out to get the super sample
		private var _sampleCount:uint;						// Number of samples added to the buffer sample
		private var _bufferSample:Number;					// Another supersample used to create a 22050Hz wave
		
		//--------------------------------------------------------------------------
		//	
		//  Sound Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Plays the sound, synthesizing the sound as it plays
		 */
		public function play():void
		{
			stop();
			
			reset(true);
			
			if (!_sound)
			{
				_sound = new Sound();
				_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			}
			
			_channel = _sound.play();
		}
		
		/**
		 * Plays a mutation of the sound, synthesizing the sound as it plays
		 * @param	mutation	Amount of mutation
		 */
		public function playMutated(mutation:Number = 0.05):void
		{
			stop();
			
			_original = clone();
			SfxrGenerator.mutate(this, mutation);
			
			reset(true);
			
			if (!_sound)
			{
				_sound = new Sound();
				_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleDataCached);
			}
			
			_channel = _sound.play();
		}
		
		/**
		 * Stops the currently playing sound
		 */
		public function stop():void
		{
			if(_channel) 
			{
				_channel.stop();
				_channel = null;
			}
			
			if(_original)
			{
				copyFrom(_original, false);
				_original = null;
			}
		}
		
		/**
		 * Synthesizes a chunk of the sound to play
		 * @param	e	SampleDataEvent to write data to
		 */
		private function onSampleData(e:SampleDataEvent):void
		{
			synthWave(e.data, 3072, true);
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Cached Sound Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Plays the waveData of the wave, using the FP10 Sound API
		 */
		public function playCached():void
		{
			stop();
			
			if (!_cachedWave) cacheSound();
			
			_waveData = _cachedWave;
			
			playWaveData();
		}
		
		/**
		 * Plays a slightly modified version of the sound, without changing the original data
		 * @param	mutations	Number of mutations to cache
		 * @param	mutation	Amount of mutation
		 */
		public function playCachedMutation(mutations:uint = 20, mutation:Number = 0.05):void
		{
			stop();
			
			if(!_cachedMutations) cacheMutations(mutations, mutation);
			
			_waveData = _cachedMutations[uint(Math.random() * _cachedMutationsNum)];
			
			playWaveData();
		}
		
		/**
		 * Plays the curent wave data
		 */
		private function playWaveData():void
		{
			_waveDataLength = _waveData.length;
			_waveData.position = 0;
			_waveDataPos = 0;
			_waveDataBytes = 24576;
			
			if (!_sound)
			{
				_sound = new Sound();
				_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleDataCached);
			}
			
			_channel = _sound.play();
		}
		
		/**
		 * Reads out chuncks of data from the waveData wave and writes it to the soundcard
		 * @param	e	SampleDataEvent to write data to
		 */
		private function onSampleDataCached(e:SampleDataEvent):void
		{
			if(_waveDataPos + _waveDataBytes > _waveDataLength) _waveDataBytes = _waveDataLength - _waveDataPos;
			
			if(_waveDataBytes > 0) e.data.writeBytes(_waveData, _waveDataPos, _waveDataBytes);
			
			_waveDataPos += _waveDataBytes;
		}
		
		/**
		 * Synthesize the playable sound
		 */
		public function cacheSound():void
		{
			validate();
			reset(true);
			
			_cachedWave = new ByteArray();
			synthWave(_cachedWave, _envelopeFullLength, true);
			
			var length:uint = _cachedWave.length;
			
			if(length < 24576)
			{
				// If the sound is smaller than the buffer length, add silence to allow it to play
				_cachedWave.position = length;
				for(var i:uint = 0, l:uint = 24576 - length; i < l; i++) _cachedWave.writeFloat(0.0);
			}
		}
		
		/**
		 * Caches a series of mutations on the source sound
		 * @param	mutations	Number of mutations to cache
		 * @param	mutation	Amount of mutation
		 */
		public function cacheMutations(mutations:uint, mutation:Number = 0.05):void
		{
			_cachedMutationsNum = mutations;
			var cachedMutations:Vector.<ByteArray> = new Vector.<ByteArray>(mutations, true);
			
			var original:SfxrSynth = clone();
			
			for(var i:uint = 0; i < _cachedMutationsNum; i++)
			{
				SfxrGenerator.mutate(this, mutation);
				cacheSound();
				cachedMutations[i] = _cachedWave;
				copyFrom(original, false);
			}
			
			_cachedMutations = cachedMutations;
		}
		
		/**
		 * Deletes the current wave data, forcing it to be synthesized again on the next play
		 */
		public function deleteCache():void
		{
			_cachedWave = null;
			_cachedMutations = null;
			
			stop();
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Synth Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Makes sure all settings values are within the correct range
		 */
		public function validate():void
		{
			if (waveType > 3) waveType = 0;
			if (sampleRate != 22050) sampleRate = 44100;
			if (bitDepth != 8) bitDepth = 16;
			
			masterVolume = 			clamp1(masterVolume);
			attackTime =  			clamp1(attackTime);
			sustainTime =  			clamp1(sustainTime);
			sustainPunch =  		clamp1(sustainPunch);
			decayTime =  			clamp1(decayTime);
			startFrequency =  		clamp1(startFrequency);
			minFrequency =  		clamp1(minFrequency);
			slide =  				clamp2(slide);
			deltaSlide =  			clamp2(deltaSlide);
			vibratoDepth =  		clamp1(vibratoDepth);
			vibratoSpeed =  		clamp1(vibratoSpeed);
			changeAmount =  		clamp2(changeAmount);
			changeSpeed =  			clamp1(changeSpeed);
			squareDuty =  			clamp1(squareDuty);
			dutySweep =  			clamp2(dutySweep);
			repeatSpeed =  			clamp1(repeatSpeed);
			phaserOffset =  		clamp2(phaserOffset);
			phaserSweep =  			clamp2(phaserSweep);
			lpFilterCutoff =  		clamp1(lpFilterCutoff);
			lpFilterCutoffSweep =  	clamp2(lpFilterCutoffSweep);
			lpFilterResonance =  	clamp1(lpFilterResonance);
			hpFilterCutoff =  		clamp1(hpFilterCutoff);
			hpFilterCutoffSweep =  	clamp2(hpFilterCutoffSweep);
		}
		
		/**
		 * Clams a value to betwen 0 and 1
		 * @param	value	Input value
		 * @return			The value clamped between 0 and 1
		 */
		private function clamp1(value:Number):Number { return (value > 1.0) ? 1.0 : ((value < 0.0) ? 0.0 : value); }
		
		/**
		 * Clams a value to betwen -1 and 1
		 * @param	value	Input value
		 * @return			The value clamped between -1 and 1
		 */
		private function clamp2(value:Number):Number { return (value > 1.0) ? 1.0 : ((value < -1.0) ? -1.0 : value); }
		
		/**
		 * Resets the runing variables
		 * Used once at the start (total reset) and for the repeat effect (partial reset)
		 * @param	totalReset	If the reset is total
		 */
		private function reset(totalReset:Boolean):void
		{
			_period = 100.0 / (startFrequency * startFrequency + 0.001);
			_maxPeriod = 100.0 / (minFrequency * minFrequency + 0.001);
			
			_slide = 1.0 - slide * slide * slide * 0.01;
			_deltaSlide = -deltaSlide * deltaSlide * deltaSlide * 0.000001;
			
			_squareDuty = 0.5 - squareDuty * 0.5;
			_dutySweep = -dutySweep * 0.00005;
			
			if (changeAmount > 0.0) _changeAmount = 1.0 - changeAmount * changeAmount * 0.9;
			else 					_changeAmount = 1.0 + changeAmount * changeAmount * 10.0;
			
			_changeTime = 0;
			
			if(changeSpeed == 1.0) 	_changeLimit = 0;
			else 					_changeLimit = (1.0 - changeSpeed) * (1.0 - changeSpeed) * 20000 + 32;
			
			if(totalReset)
			{
				_phase = 0;
				
				_lpFilterPos = 0.0;
				_lpFilterDeltaPos = 0.0;
				_lpFilterCutoff = lpFilterCutoff * lpFilterCutoff * lpFilterCutoff * 0.1;
				_lpFilterDeltaCutoff = 1.0 + lpFilterCutoffSweep * 0.0001;
				_lpFilterDamping = 5.0 / (1.0 + lpFilterResonance * lpFilterResonance * 20.0) * (0.01 + _lpFilterCutoff)
				if(_lpFilterDamping > 0.8) _lpFilterDamping = 0.8;
				
				_hpFilterPos = 0.0;
				_hpFilterCutoff = hpFilterCutoff * hpFilterCutoff * 0.1;
				_hpFilterDeltaCutoff = 1.0 + hpFilterCutoffSweep * 0.0003;
				
				_vibratoPhase = 0.0;
				_vibratoSpeed = vibratoSpeed * vibratoSpeed * 0.01;
				_vibratoAmplitude = vibratoDepth * 0.5;
				
				_envelopeVolume = 0.0;
				_envelopeStage = 0;
				_envelopeTime = 0;
				_envelopeLength0 = attackTime * attackTime * 100000.0;
				_envelopeLength1 = sustainTime * sustainTime * 100000.0;
				_envelopeLength2 = decayTime * decayTime * 100000.0;
				_envelopeLength = _envelopeLength0;
				_envelopeFullLength = _envelopeLength0 + _envelopeLength1 + _envelopeLength2;
				
				_envelopeOverLength0 = 1.0 / _envelopeLength0;
				_envelopeOverLength1 = 1.0 / _envelopeLength1;
				_envelopeOverLength2 = 1.0 / _envelopeLength2;
				
				_phaserOffset = phaserOffset * phaserOffset * 1020.0;
				if(phaserOffset < 0.0) _phaserOffset = -_phaserOffset;
				_phaserDeltaOffset = phaserSweep * phaserSweep;
				if(_phaserDeltaOffset < 0.0) _phaserDeltaOffset = -_phaserDeltaOffset;
				_phaserPos = 0;
				
				if(!_phaserBuffer) _phaserBuffer = new Vector.<Number>(1024, true);
				if(!_noiseBuffer) _noiseBuffer = new Vector.<Number>(32, true);
				
				for(var i:uint = 0; i < 1024; i++) _phaserBuffer[i] = 0.0;
				for(i = 0; i < 32; i++) _noiseBuffer[i] = Math.random() * 2.0 - 1.0;
				
				_repeatTime = 0;
				
				if (repeatSpeed == 0.0) _repeatLimit = 0;
				else 					_repeatLimit = int((1.0-repeatSpeed) * (1.0-repeatSpeed) * 20000) + 32;
			}
		}
		
		/**
		 * Writes the wave to the supplied buffer ByteArray
		 * @param	buffer		A ByteArray to write the wave to
		 * @param	waveData		If the wave should be written for the waveData 
		 */
		private function synthWave(buffer:ByteArray, length:uint, waveData:Boolean = false):void
		{
			var finished:Boolean = false;
			
			_sampleCount = 0;
			_bufferSample = 0.0;
			
			for(var i:uint = 0; i < length; i++)
			{
				if(finished) return;
				
				if(_repeatLimit != 0)
				{
					if(++_repeatTime >= _repeatLimit)
					{
						_repeatTime = 0;
						reset(false);
					}
				}
				
				if(_changeLimit != 0)
				{
					if(++_changeTime >= _changeLimit)
					{
						_changeLimit = 0;
						_period *= _changeAmount;
					}
				}
				
				_slide += _deltaSlide;
				_period = _period * _slide;
				
				if(_period > _maxPeriod)
				{
					_period = _maxPeriod;
					if(minFrequency > 0.0) finished = true;
				}
				
				_periodTemp = _period;
				
				if(_vibratoAmplitude > 0.0)
				{
					_vibratoPhase += _vibratoSpeed;
					_periodTemp = _period * (1.0 + Math.sin(_vibratoPhase) * _vibratoAmplitude);
				}
				
				_periodTemp = int(_periodTemp);
				if(_periodTemp < 8) _periodTemp = 8;
				
				_squareDuty += _dutySweep;
					 if(_squareDuty < 0.0) _squareDuty = 0.0;
				else if(_squareDuty > 0.5) _squareDuty = 0.5;
				
				if(++_envelopeTime > _envelopeLength)
				{
					_envelopeTime = 0;
					
					switch(++_envelopeStage)
					{
						case 1: _envelopeLength = _envelopeLength1; break;
						case 2: _envelopeLength = _envelopeLength2; break;
					}
				}
				
				switch(_envelopeStage)
				{
					case 0: _envelopeVolume = _envelopeTime * _envelopeOverLength0; 									break;
					case 1: _envelopeVolume = 1.0 + (1.0 - _envelopeTime * _envelopeOverLength1) * 2.0 * sustainPunch; 	break;
					case 2: _envelopeVolume = 1.0 - _envelopeTime * _envelopeOverLength2; 								break;
					case 3: _envelopeVolume = 0.0; finished = true; 													break;
				}
				
				_phaserOffset += _phaserDeltaOffset;
				_phaserInt = int(_phaserOffset);
					 if(_phaserInt < 0) 	_phaserInt = -_phaserInt;
				else if(_phaserInt > 1023) 	_phaserInt = 1023;
				
				if(_hpFilterDeltaCutoff != 0.0)
				{
					_hpFilterCutoff *- _hpFilterDeltaCutoff;
						 if(_hpFilterCutoff < 0.00001) 	_hpFilterCutoff = 0.00001;
					else if(_hpFilterCutoff > 0.1) 		_hpFilterCutoff = 0.1;
				}
				
				_superSample = 0.0;
				for(var j:int = 0; j < 8; j++)
				{
					_sample = 0.0;
					_phase++;
					if(_phase >= _periodTemp)
					{
						_phase = _phase % _periodTemp;
						if(waveType == 3) 
						{ 
							for(var n:uint = 0; n < 32; n++) _noiseBuffer[n] = Math.random() * 2.0 - 1.0;
						}
					}
					
					_pos = Number(_phase) / _periodTemp;
					
					switch(waveType)
					{
						case 0: _sample = (_pos < _squareDuty) ? 0.5 : -0.5; 					break;
						case 1: _sample = 1.0 - _pos * 2.0;										break;
						case 2: _sample = Math.sin(_pos * Math.PI * 2.0);						break;
						case 3: _sample = _noiseBuffer[uint(_phase * 32 / int(_periodTemp))];	break;
					}
					
					_lpFilterOldPos = _lpFilterPos;
					_lpFilterCutoff *= _lpFilterDeltaCutoff;
						 if(_lpFilterCutoff < 0.0) _lpFilterCutoff = 0.0;
					else if(_lpFilterCutoff > 0.1) _lpFilterCutoff = 0.1;
					
					if(lpFilterCutoff != 1.0)
					{
						_lpFilterDeltaPos += (_sample - _lpFilterPos) * _lpFilterCutoff * 4;
						_lpFilterDeltaPos -= _lpFilterDeltaPos * _lpFilterDamping;
					}
					else
					{
						_lpFilterPos = _sample;
						_lpFilterDeltaPos = 0.0;
					}
					
					_lpFilterPos += _lpFilterDeltaPos;
					
					_hpFilterPos += _lpFilterPos - _lpFilterOldPos;
					_hpFilterPos -= _hpFilterPos * _lpFilterCutoff;
					_sample = _hpFilterPos;
					
					_phaserBuffer[_phaserPos&1023] = _sample;
					_sample += _phaserBuffer[(_phaserPos - _phaserInt + 1024) & 1023];
					_phaserPos = (_phaserPos + 1) & 1023;
					
					_superSample += _sample;
				}
				
				_superSample = masterVolume * masterVolume * _envelopeVolume * _superSample / 8.0;
				
				if(_superSample > 1.0) 	_superSample = 1.0;
				if(_superSample < -1.0) _superSample = -1.0;
				
				if(waveData)
				{
					buffer.writeFloat(_superSample);
					buffer.writeFloat(_superSample);
				}
				else
				{
					_bufferSample += _superSample;
				
					_sampleCount++;
					
					if(sampleRate == 44100 || _sampleCount == 2)
					{
						_bufferSample /= _sampleCount;
						_sampleCount = 0;
						
						if(bitDepth == 16) 	buffer.writeShort(int(32000.0 * _bufferSample));
						else 				buffer.writeByte(_bufferSample * 127 + 128);
						
						_bufferSample = 0.0;
					}
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Settings String Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Returns a string representation of the parameters for copy/paste sharing
		 * @return	A comma-delimited list of parameter values
		 */
		public function getSettingsString():String
		{
			var string:String = String(waveType);
			string += "," + to3DP(attackTime) + 			"," + to3DP(sustainTime) 
					+ "," + to3DP(sustainPunch) + 			"," + to3DP(decayTime) 
					+ "," + to3DP(startFrequency) + 		"," + to3DP(minFrequency)
					+ "," + to3DP(slide) + 					"," + to3DP(deltaSlide)
					+ "," + to3DP(vibratoDepth) + 			"," + to3DP(vibratoSpeed)
					+ "," + to3DP(changeAmount) + 			"," + to3DP(changeSpeed)
					+ "," + to3DP(squareDuty) + 			"," + to3DP(dutySweep)
					+ "," + to3DP(repeatSpeed) + 			"," + to3DP(phaserOffset)
					+ "," + to3DP(phaserSweep) + 			"," + to3DP(lpFilterCutoff)
					+ "," + to3DP(lpFilterCutoffSweep) + 	"," + to3DP(lpFilterResonance)
					+ "," + to3DP(hpFilterCutoff)+ 			"," + to3DP(hpFilterCutoffSweep)
					+ "," + to3DP(masterVolume);		
			
			return string;
		}
		
		/**
		 * Returns the number as a string to 3 decimal places
		 * @param	value	Number to convert
		 * @return			Number to 3dp as a string
		 */
		private function to3DP(value:Number):String
		{
			if (value < 0.001 && value > -0.001) return "";
			
			var string:String = String(value);
			var split:Array = string.split(".");
			if (split.length == 1) 	return string;
			else 					
			{
				var out:String = split[0] + "." + split[1].substr(0, 3);
				while (out.substr(out.length - 1, 1) == "0") out = out.substr(0, out.length - 1);
				
				return out;
			}
		}
		
		/**
		 * Parses a settings string into the parameters
		 * @param	string	Settings string to parse
		 * @return			If the string successfully parsed
		 */
		public function setSettingsString(string:String):Boolean
		{
			deleteCache();
			var values:Array = string.split(",");
			
			if (values.length != 24) return false;
			
			waveType = 				uint(values[0]) || 0;
			attackTime =  			Number(values[1]) || 0;
			sustainTime =  			Number(values[2]) || 0;
			sustainPunch =  		Number(values[3]) || 0;
			decayTime =  			Number(values[4]) || 0;
			startFrequency =  		Number(values[5]) || 0;
			minFrequency =  		Number(values[6]) || 0;
			slide =  				Number(values[7]) || 0;
			deltaSlide =  			Number(values[8]) || 0;
			vibratoDepth =  		Number(values[9]) || 0;
			vibratoSpeed =  		Number(values[10]) || 0;
			changeAmount =  		Number(values[11]) || 0;
			changeSpeed =  			Number(values[12]) || 0;
			squareDuty =  			Number(values[13]) || 0;
			dutySweep =  			Number(values[14]) || 0;
			repeatSpeed =  			Number(values[15]) || 0;
			phaserOffset =  		Number(values[16]) || 0;
			phaserSweep =  			Number(values[17]) || 0;
			lpFilterCutoff =  		Number(values[18]) || 0;
			lpFilterCutoffSweep =  	Number(values[19]) || 0;
			lpFilterResonance =  	Number(values[20]) || 0;
			hpFilterCutoff =  		Number(values[21]) || 0;
			hpFilterCutoffSweep =  	Number(values[22]) || 0;
			masterVolume = 			Number(values[23]) || 0;
			
			validate();
			
			return true;
		}   
		
		//--------------------------------------------------------------------------
		//	
		//  .wav File Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Returns a ByteArray of the wave in the form of a .wav file, ready to be saved out
		 * @return	Wave in a .wav file
		 */
		public function getWavFile():ByteArray
		{
			stop();
			
			reset(true);
			
			var soundLength:uint = _envelopeFullLength;
			if (bitDepth == 16) soundLength *= 2;
			if (sampleRate == 22050) soundLength /= 2;
			
			var filesize:int = 36 + soundLength;
			var blockAlign:int = bitDepth / 8;
			var bytesPerSec:int = sampleRate * blockAlign;
			
			var wav:ByteArray = new ByteArray();
			
			// Header
			wav.endian = Endian.BIG_ENDIAN;
			wav.writeUnsignedInt(0x52494646);		// Chunk ID "RIFF"
			wav.endian = Endian.LITTLE_ENDIAN;
			wav.writeUnsignedInt(filesize);			// Chunck Data Size
			wav.endian = Endian.BIG_ENDIAN;
			wav.writeUnsignedInt(0x57415645);		// RIFF Type "WAVE"
			
			// Format Chunk
			wav.endian = Endian.BIG_ENDIAN;
			wav.writeUnsignedInt(0x666D7420);		// Chunk ID "fmt "
			wav.endian = Endian.LITTLE_ENDIAN;
			wav.writeUnsignedInt(16);				// Chunk Data Size
			wav.writeShort(1);						// Compression Code PCM
			wav.writeShort(1);						// Number of channels
			wav.writeUnsignedInt(sampleRate);		// Sample rate
			wav.writeUnsignedInt(bytesPerSec);		// Average bytes per second
			wav.writeShort(blockAlign);				// Block align
			wav.writeShort(bitDepth);				// Significant bits per sample
			
			// Data Chunk
			wav.endian = Endian.BIG_ENDIAN;
			wav.writeUnsignedInt(0x64617461);		// Chunk ID "data"
			wav.endian = Endian.LITTLE_ENDIAN;
			wav.writeUnsignedInt(soundLength);		// Chunk Data Size
			
			synthWave(wav, _envelopeFullLength);
			
			wav.position = 0;
			
			return wav;
		}
		
		//--------------------------------------------------------------------------
		//	
		//  Copying Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Returns a copy of this SfxrSynth with all settings duplicated
		 * @return	A copy of this SfxrSynth
		 */
		public function clone():SfxrSynth
		{
			var out:SfxrSynth = new SfxrSynth();
			out.copyFrom(this, false);		
			
			return out;
		}
		
		/**
		 * Copies parameters from another instance
		 * @param	synth	Instance to copy parameters from
		 */
		public function copyFrom(synth:SfxrSynth, shouldDeleteCache:Boolean = true):void
		{
			if(shouldDeleteCache) deleteCache();
			
			waveType = 				synth.waveType;
			attackTime =            synth.attackTime;
			sustainTime =           synth.sustainTime;
			sustainPunch =          synth.sustainPunch;
			decayTime =             synth.decayTime;
			startFrequency =        synth.startFrequency;
			minFrequency =          synth.minFrequency;
			slide =                 synth.slide;
			deltaSlide =            synth.deltaSlide;
			vibratoDepth =          synth.vibratoDepth;
			vibratoSpeed =          synth.vibratoSpeed;
			changeAmount =          synth.changeAmount;
			changeSpeed =           synth.changeSpeed;
			squareDuty =            synth.squareDuty;
			dutySweep =             synth.dutySweep;
			repeatSpeed =           synth.repeatSpeed;
			phaserOffset =          synth.phaserOffset;
			phaserSweep =           synth.phaserSweep;
			lpFilterCutoff =        synth.lpFilterCutoff;
			lpFilterCutoffSweep =   synth.lpFilterCutoffSweep;
			lpFilterResonance =     synth.lpFilterResonance;
			hpFilterCutoff =        synth.hpFilterCutoff;
			hpFilterCutoffSweep =   synth.hpFilterCutoffSweep;
			masterVolume = 			synth.masterVolume;
			
			validate();
		}                        
	}
}