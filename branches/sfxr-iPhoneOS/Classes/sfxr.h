/*
 *  sfxr.h
 *  sfxr
 *
 *  Original code by Tomas Pettersson 2007.
 *
 *  Modifications are copyright Christopher Gassib 2009.
 *  This file is released under the MIT license as described in readme.txt
 *
 */

#ifndef SFXR_H
#define SFXR_H

enum WaveformGenerator {
    SquareWave,
    Sawtooth,
    SineWave,
    Noise
};

class sfxr
: public SampleSourceFunctor
{
private:
    int wave_type;

    float p_base_freq;
    float p_freq_limit;
    float p_freq_ramp;
    float p_freq_dramp;
    float p_duty;
    float p_duty_ramp;
    
    float p_vib_strength;
    float p_vib_speed;
    float p_vib_delay;
    
    float p_env_attack;
    float p_env_sustain;
    float p_env_decay;
    float p_env_punch;
    
    bool filter_on;
    float p_lpf_resonance;
    float p_lpf_freq;
    float p_lpf_ramp;
    float p_hpf_freq;
    float p_hpf_ramp;
    
    float p_pha_offset;
    float p_pha_ramp;
    
    float p_repeat_speed;
    
    float p_arp_speed;
    float p_arp_mod;
    
    float master_vol;
    
    float sound_vol;

    bool playing_sample;
    int phase;
    double fperiod;
    double fmaxperiod;
    double fslide;
    double fdslide;
    int period;
    float square_duty;
    float square_slide;
    int env_stage;
    int env_time;
    int env_length[3];
    float env_vol;
    float fphase;
    float fdphase;
    int iphase;
    float phaser_buffer[1024];
    int ipp;
    float noise_buffer[32];
    float fltp;
    float fltdp;
    float fltw;
    float fltw_d;
    float fltdmp;
    float fltphp;
    float flthp;
    float flthp_d;
    float vib_phase;
    float vib_speed;
    float vib_amp;
    int rep_time;
    int rep_limit;
    int arp_time;
    int arp_limit;
    double arp_mod;

    int wav_bits;
    int wav_freq;
    
    int file_sampleswritten;
    float filesample;
    int fileacc;

    bool mute_stream;

    static const unsigned int fileVersion = 102;

    // Internal sfxr implementation:
    void ResetParams();
    void ResetSample(bool restart);
    void SynthSample(int length, float* buffer, FILE* file);

public:
    sfxr();
    sfxr(const sfxr& original);
    virtual ~sfxr();
    
    sfxr& operator =(const sfxr& rhs);

    virtual bool operator ()(unsigned char* sampleBuffer, int byteCount);

    bool LoadSettings(std::istream& stream);
    bool SaveSettings(std::ostream& stream) const;
    bool LoadSettings(const char* filename);
    bool SaveSettings(const char* filename);
    bool ExportWAV(const char* filename);

    void PlaySample();

    float GetSoundVolume() const;
    void SetSoundVolume(const float value);

    WaveformGenerator GetWaveform() const;
    void SetWaveform(const WaveformGenerator waveform);

    float GetAttackTime() const;
    void SetAttackTime(const float value);

    float GetSustainTime() const;
    void SetSustainTime(const float value);

    float GetSustainPunch() const;
    void SetSustainPunch(const float value);

    float GetDecayTime() const;
    void SetDecayTime(const float value);

    float GetStartFrequency() const;
    void SetStartFrequency(const float value);

    float GetMinimumFrequency() const;
    void SetMinimumFrequency(const float value);

    float GetSlide() const;
    void SetSlide(const float value);

    float GetDeltaSlide() const;
    void SetDeltaSlide(const float value);

    float GetVibratoDepth() const;
    void SetVibratoDepth(const float value);

    float GetVibratoSpeed() const;
    void SetVibratoSpeed(const float value);

    float GetChangeAmount() const;
    void SetChangeAmount(const float value);

    float GetChangeSpeed() const;
    void SetChangeSpeed(const float value);

    float GetSquareDuty() const;
    void SetSquareDuty(const float value);

    float GetDutySweep() const;
    void SetDutySweep(const float value);

    float GetRepeatSpeed() const;
    void SetRepeatSpeed(const float value);

    float GetPhaserOffset() const;
    void SetPhaserOffset(const float value);

    float GetPhaserSweep() const;
    void SetPhaserSweep(const float value);

    float GetLowPassFilterCutoff() const;
    void SetLowPassFilterCutoff(const float value);

    float GetLowPassFilterCutoffSweep() const;
    void SetLowPassFilterCutoffSweep(const float value);

    float GetLowPassFilterResonance() const;
    void SetLowPassFilterResonance(const float value);

    float GetHighPassFilterCutoff() const;
    void SetHighPassFilterCutoff(const float value);

    float GetHighPassFilterCutoffSweep() const;
    void SetHighPassFilterCutoffSweep(const float value);

    void PickupCoinButtonPressed();
    void LaserShootButtonPressed();
    void ExplosionButtonPressed();
    void PowerupButtonPressed();
    void HitHurtButtonPressed();
    void JumpButtonPressed();
    void BlitSelectButtonPressed();
    void MutateButtonPressed();
    void RandomizeButtonPressed();
};

#endif
