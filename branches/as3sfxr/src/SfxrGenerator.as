package 
{
	
	/**
	 * SfxrGenerator
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
	public class SfxrGenerator 
	{
		/**
		 * Sets the parameters to generate a pickup/coin sound
		 */
		public static function generatePickupCoin(synth:SfxrSynth):void
		{
			synth.deleteCache();
			resetParams(synth);
			
			synth.startFrequency = 0.4 + Math.random() * 0.5;
			
			synth.sustainTime = Math.random() * 0.1;
			synth.decayTime = 0.1 + Math.random() * 0.4;
			synth.sustainPunch = 0.3 + Math.random() * 0.3;
			
			if(Math.random() < 0.5) 
			{
				synth.changeSpeed = 0.5 + Math.random() * 0.2;
				synth.changeAmount = 0.2 + Math.random() * 0.4;
			}
		}
		
		/**
		 * Sets the parameters to generate a laser/shoot sound
		 */
		public static function generateLaserShoot(synth:SfxrSynth):void
		{
			synth.deleteCache();
			resetParams(synth);
			
			synth.waveType = uint(Math.random() * 3);
			if(synth.waveType == 2 && Math.random() < 0.5) synth.waveType = uint(Math.random() * 2);
			
			synth.startFrequency = 0.5 + Math.random() * 0.5;
			synth.minFrequency = synth.startFrequency - 0.2 - Math.random() * 0.6;
			if(synth.minFrequency < 0.2) synth.minFrequency = 0.2;
			
			synth.slide = -0.15 - Math.random() * 0.2;
			
			if(Math.random() < 0.33)
			{
				synth.startFrequency = 0.3 + Math.random() * 0.6;
				synth.minFrequency = Math.random() * 0.1;
				synth.slide = -0.35 - Math.random() * 0.3;
			}
			
			if(Math.random() < 0.5) 
			{
				synth.squareDuty = Math.random() * 0.5;
				synth.dutySweep = Math.random() * 0.2;
			}
			else
			{
				synth.squareDuty = 0.4 + Math.random() * 0.5;
				synth.dutySweep =- Math.random() * 0.7;	
			}
			
			synth.sustainTime = 0.1 + Math.random() * 0.2;
			synth.decayTime = Math.random() * 0.4;
			if(Math.random() < 0.5) synth.sustainPunch = Math.random() * 0.3;
			
			if(Math.random() < 0.33)
			{
				synth.phaserOffset = Math.random() * 0.2;
				synth.phaserSweep = -Math.random() * 0.2;
			}
			
			if(Math.random() < 0.5) synth.hpFilterCutoff = Math.random() * 0.3;
		}
		
		/**
		 * Sets the parameters to generate an explosion sound
		 */
		public static function generateExplosion(synth:SfxrSynth):void
		{
			synth.deleteCache();
			resetParams(synth);
			synth.waveType = 3;
			
			if(Math.random() < 0.5)
			{
				synth.startFrequency = 0.1 + Math.random() * 0.4;
				synth.slide = -0.1 + Math.random() * 0.4;
			}
			else
			{
				synth.startFrequency = 0.2 + Math.random() * 0.7;
				synth.slide = -0.2 - Math.random() * 0.2;
			}
			
			synth.startFrequency *= synth.startFrequency;
			
			if(Math.random() < 0.2) synth.slide = 0.0;
			if(Math.random() < 0.33) synth.repeatSpeed = 0.3 + Math.random() * 0.5;
			
			synth.sustainTime = 0.1 + Math.random() * 0.3;
			synth.decayTime = Math.random() * 0.5;
			synth.sustainPunch = 0.2 + Math.random() * 0.6;
			
			if(Math.random() < 0.5)
			{
				synth.phaserOffset = -0.3 + Math.random() * 0.9;
				synth.phaserSweep = -Math.random() * 0.3;
			}
			
			if(Math.random() < 0.33)
			{
				synth.changeSpeed = 0.6 + Math.random() * 0.3;
				synth.changeAmount = 0.8 - Math.random() * 1.6;
			}
		}
		
		/**
		 * Sets the parameters to generate a powerup sound
		 */
		public static function generatePowerup(synth:SfxrSynth):void
		{
			synth.deleteCache();
			resetParams(synth);
			
			if(Math.random() < 0.5) synth.waveType = 1;
			else 					synth.squareDuty = Math.random() * 0.6;
			
			if(Math.random() < 0.5)
			{
				synth.startFrequency = 0.2 + Math.random() * 0.3;
				synth.slide = 0.1 + Math.random() * 0.4;
				synth.repeatSpeed = 0.4 + Math.random() * 0.4;
			}
			else
			{
				synth.startFrequency = 0.2 + Math.random() * 0.3;
				synth.slide = 0.05 + Math.random() * 0.2;
				
				if(Math.random() < 0.5)
				{
					synth.vibratoDepth = Math.random() * 0.7;
					synth.vibratoSpeed = Math.random() * 0.6;
				}
			}
			
			synth.sustainTime = Math.random() * 0.4;
			synth.decayTime = 0.1 + Math.random() * 0.4;
		}
		
		/**
		 * Sets the parameters to generate a hit/hurt sound
		 */
		public static function generateHitHurt(synth:SfxrSynth):void
		{
			synth.deleteCache();
			resetParams(synth);
			synth.waveType = uint(Math.random() * 3);
			if(synth.waveType == 2) synth.waveType = 3;
			else if(synth.waveType == 0) synth.squareDuty = Math.random() * 0.6;
			
			synth.startFrequency = 0.2 + Math.random() * 0.6;
			synth.slide = -0.3 - Math.random() * 0.4;
			
			synth.sustainTime = Math.random() * 0.1;
			synth.decayTime = 0.1 + Math.random() * 0.2;
			
			if(Math.random() < 0.5) synth.hpFilterCutoff = Math.random() * 0.3;
		}
		
		/**
		 * Sets the parameters to generate a jump sound
		 */
		public static function generateJump(synth:SfxrSynth):void
		{
			synth.deleteCache();
			resetParams(synth);
			
			synth.waveType = 0;
			synth.squareDuty = Math.random() * 0.6;
			synth.startFrequency = 0.3 + Math.random() * 0.3;
			synth.slide = 0.1 + Math.random() * 0.2;
			
			synth.sustainTime = 0.1 + Math.random() * 0.3;
			synth.decayTime = 0.1 + Math.random() * 0.2;
			
			if(Math.random() < 0.5) synth.hpFilterCutoff = Math.random() * 0.3;
			if(Math.random() < 0.5) synth.lpFilterCutoff = 1.0 - Math.random() * 0.6;
		}
		
		/**
		 * Sets the parameters to generate a blip/select sound
		 */
		public static function generateBlipSelect(synth:SfxrSynth):void
		{
			synth.deleteCache();
			resetParams(synth);
			
			synth.waveType = uint(Math.random() * 2);
			if(synth.waveType == 0) synth.squareDuty = Math.random() * 0.6;
			
			synth.startFrequency = 0.2 + Math.random() * 0.4;
			
			synth.sustainTime = 0.1 + Math.random() * 0.1;
			synth.decayTime = Math.random() * 0.2;
			synth.hpFilterCutoff = 0.1;
		}
		
		/**
		 * Resets the parameters, used at the start of each generate function
		 */
		protected static function resetParams(synth:SfxrSynth):void
		{
			synth.waveType = 0;
			synth.startFrequency = 0.3;
			synth.minFrequency = 0.0;
			synth.slide = 0.0;
			synth.deltaSlide = 0.0;
			synth.squareDuty = 0.0;
			synth.dutySweep = 0.0;
			
			synth.vibratoDepth = 0.0;
			synth.vibratoSpeed = 0.0;
			
			synth.attackTime = 0.0;
			synth.sustainTime = 0.3;
			synth.decayTime = 0.4;
			synth.sustainPunch = 0.0;
			
			synth.lpFilterResonance = 0.0;
			synth.lpFilterCutoff = 1.0;
			synth.lpFilterCutoffSweep = 0.0;
			synth.hpFilterCutoff = 0.0;
			synth.hpFilterCutoffSweep = 0.0;
			
			synth.phaserOffset = 0.0;
			synth.phaserSweep = 0.0;
			
			synth.repeatSpeed = 0.0;
			
			synth.changeSpeed = 0.0;
			synth.changeAmount = 0.0;
		}
		
		/**
		 * Randomly adjusts the parameters ever so slightly
		 */
		public static function mutate(synth:SfxrSynth, mutation:Number = 0.05):void
		{
			synth.deleteCache();
			if(Math.random() < 0.5) synth.startFrequency += 		Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.minFrequency += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.slide += 					Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.deltaSlide += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.squareDuty += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.dutySweep += 				Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.vibratoDepth += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.vibratoSpeed += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.attackTime += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.sustainTime += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.decayTime += 				Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.sustainPunch += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.lpFilterCutoff += 		Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.lpFilterCutoffSweep += 	Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.lpFilterResonance += 		Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.hpFilterCutoff += 		Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.hpFilterCutoffSweep += 	Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.phaserOffset += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.phaserSweep += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.repeatSpeed += 			Math.random() * mutation*2 - mutation;
			if(Math.random() < 0.5) synth.changeSpeed += 			Math.random() * mutation*2 - mutation;
			if (Math.random() < 0.5) synth.changeAmount += 			Math.random() * mutation*2 - mutation;
			
			synth.validate();
		}
		
		/**
		 * Sets all parameters to random values
		 */
		public static function randomize(synth:SfxrSynth):void
		{
			synth.deleteCache();
			synth.waveType = uint(Math.random() * 4);
			
			synth.attackTime =  		pow(Math.random()*2-1, 4);
			synth.sustainTime =  		pow(Math.random()*2-1, 2);
			synth.sustainPunch =  		pow(Math.random()*0.8, 2);
			synth.decayTime =  			Math.random();

			synth.startFrequency =  	(Math.random() < 0.5) ? pow(Math.random()*2-1, 2) : (pow(Math.random() * 0.5, 3) + 0.5);
			synth.minFrequency =  		0.0;
			
			synth.slide =  				pow(Math.random()*2-1, 5);
			synth.deltaSlide =  		pow(Math.random()*2-1, 3);
			
			synth.vibratoDepth =  		pow(Math.random()*2-1, 3);
			synth.vibratoSpeed =  		Math.random()*2-1;
			
			synth.changeAmount =  		Math.random()*2-1;
			synth.changeSpeed =  		Math.random()*2-1;
			
			synth.squareDuty =  		Math.random()*2-1;
			synth.dutySweep =  			pow(Math.random()*2-1, 3);
			
			synth.repeatSpeed =  		Math.random()*2-1;
			
			synth.phaserOffset =  		pow(Math.random()*2-1, 3);
			synth.phaserSweep =  		pow(Math.random()*2-1, 3);
			
			synth.lpFilterCutoff =  	1 - pow(Math.random(), 3);
			synth.lpFilterCutoffSweep = pow(Math.random()*2-1, 3);
			synth.lpFilterResonance =  	Math.random()*2-1;
			
			synth.hpFilterCutoff =  	pow(Math.random(), 5);
			synth.hpFilterCutoffSweep = pow(Math.random()*2-1, 5);
			
			if(synth.attackTime + synth.sustainTime + synth.decayTime < 0.2)
			{
				synth.sustainTime = 0.2 + Math.random() * 0.3;
				synth.decayTime = 0.2 + Math.random() * 0.3;
			}
			
			if((synth.startFrequency > 0.7 && synth.slide > 0.2) || (synth.startFrequency < 0.2 && synth.slide < -0.05)) 
			{
				synth.slide = -synth.slide;
			}
			
			if(synth.lpFilterCutoff < 0.1 && synth.lpFilterCutoffSweep < -0.05) 
			{
				synth.lpFilterCutoffSweep = -synth.lpFilterCutoffSweep;
			}
		}
		
		/**
		 * Quick power function
		 * @param	base		Base to raise to power
		 * @param	power		Power to raise base by
		 * @return				The calculated power
		 */
		private static function pow(base:Number, power:int):Number
		{
			switch(power)
			{
				case 2: return base*base;
				case 3: return base*base*base;
				case 4: return base*base*base*base;
				case 5: return base*base*base*base*base;
			}
			
			return 1.0;
		}
	}
}