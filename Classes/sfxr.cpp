/*
 *  sfxr.cpp
 *  sfxr
 *
 *  Original code by Tomas Pettersson 2007.
 *
 *  Modifications are copyright Christopher Gassib 2009.
 *  This file is released under the MIT license as described in readme.txt
 *
 */

#include "sfxr_Prefix.pch"
#include "SampleSourceFunctor.h"
#include "sfxr.h"

const unsigned int sfxr::fileVersion;

const float PI = 3.14159265f;

inline int rnd(int n)
{
    return rand() % (n + 1);
}

inline float frnd(float range)
{
	return static_cast<float>(rnd(10000)) / 10000.0f * range;
}

sfxr::sfxr()
: playing_sample(false), master_vol(0.05f), sound_vol(0.5f), filesample(0.0f),
fileacc(0), wav_freq(44100), wav_bits(16), mute_stream(false), phase(0),
fperiod(0.0), fmaxperiod(0.0), fslide(0.0), fdslide(0.0), period(0),
square_duty(0.0f), square_slide(0.0f), env_stage(0), env_time(0), env_vol(0.0f),
fphase(0.0f), fdphase(0.0f), iphase(0), ipp(0), fltp(0.0f), fltdp(0.0f),
fltw(0.0f), fltw_d(0.0f), fltdmp(0.0f), fltphp(0.0f), flthp(0.0f), flthp_d(0.0f),
vib_phase(0.0f), vib_speed(0.0f), vib_amp(0.0f), rep_time(0), rep_limit(0),
arp_time(0), arp_limit(0), arp_mod(0.0), file_sampleswritten(0)
{
    srand(time(NULL));
    ResetParams();
    
    memset(env_length, 0, sizeof(env_length));
    memset(phaser_buffer, 0, sizeof(phaser_buffer));
    memset(noise_buffer, 0, sizeof(noise_buffer));
}

sfxr::sfxr(const sfxr& original)
: playing_sample(original.playing_sample), master_vol(original.master_vol), sound_vol(original.sound_vol),
filesample(original.filesample), fileacc(original.fileacc), wav_freq(original.wav_freq),
wav_bits(original.wav_bits), mute_stream(original.mute_stream), phase(original.phase),
fperiod(original.fperiod), fmaxperiod(original.fmaxperiod), fslide(original.fslide),
fdslide(original.fdslide), period(original.period), square_duty(original.square_duty),
square_slide(original.square_slide), env_stage(original.env_stage), env_time(original.env_time),
env_vol(original.env_vol), fphase(original.fphase), fdphase(original.fdphase), iphase(original.iphase),
ipp(original.ipp), fltp(original.fltp), fltdp(original.fltdp), fltw(original.fltw),
fltw_d(original.fltw_d), fltdmp(original.fltdmp), fltphp(original.fltphp), flthp(original.flthp),
flthp_d(original.flthp_d), vib_phase(original.vib_phase), vib_speed(original.vib_speed),
vib_amp(original.vib_amp), rep_time(original.rep_time), rep_limit(original.rep_limit),
arp_time(original.arp_time), arp_limit(original.arp_limit), arp_mod(original.arp_mod),
file_sampleswritten(original.file_sampleswritten), wave_type(original.wave_type),
p_base_freq(original.p_base_freq), p_freq_limit(original.p_freq_limit), p_freq_ramp(original.p_freq_ramp),
p_freq_dramp(original.p_freq_dramp), p_duty(original.p_duty), p_duty_ramp(original.p_duty_ramp),
p_vib_strength(original.p_vib_strength), p_vib_speed(original.p_vib_speed),
p_vib_delay(original.p_vib_delay),  p_env_attack(original.p_env_attack),
p_env_sustain(original.p_env_sustain), p_env_decay(original.p_env_decay),
p_env_punch(original.p_env_punch), filter_on(original.filter_on),
p_lpf_resonance(original.p_lpf_resonance), p_lpf_freq(original.p_lpf_freq),
p_lpf_ramp(original.p_lpf_ramp), p_hpf_freq(original.p_hpf_freq), p_hpf_ramp(original.p_hpf_ramp),
p_pha_offset(original.p_pha_offset), p_pha_ramp(original.p_pha_ramp),
p_repeat_speed(original.p_repeat_speed), p_arp_speed(original.p_arp_speed), p_arp_mod(original.p_arp_mod)
{
    memcpy(env_length, original.env_length, sizeof(env_length));
    memcpy(phaser_buffer, original.phaser_buffer, sizeof(phaser_buffer));
    memcpy(noise_buffer, original.phaser_buffer, sizeof(noise_buffer));
}

sfxr::~sfxr()
{
}

sfxr& sfxr::operator =(const sfxr& rhs)
{
    if (&rhs == this)
    {
        return *this;
    }

    playing_sample = rhs.playing_sample;
    master_vol = rhs.master_vol;
    sound_vol = rhs.sound_vol;
    filesample = rhs.filesample;
    fileacc = rhs.fileacc;
    wav_freq = rhs.wav_freq;
    wav_bits = rhs.wav_bits;
    mute_stream = rhs.mute_stream;
    phase = rhs.phase;
    fperiod = rhs.fperiod;
    fmaxperiod = rhs.fmaxperiod;
    fslide = rhs.fslide;
    fdslide = rhs.fdslide;
    period = rhs.period;
    square_duty = rhs.square_duty;
    square_slide = rhs.square_slide;
    env_stage = rhs.env_stage;
    env_time = rhs.env_time;
    env_vol = rhs.env_vol;
    fphase = rhs.fphase;
    fdphase = rhs.fdphase;
    iphase = rhs.iphase;
    ipp = rhs.ipp;
    fltp = rhs.fltp;
    fltdp = rhs.fltdp;
    fltw = rhs.fltw;
    fltw_d = rhs.fltw_d;
    fltdmp = rhs.fltdmp;
    fltphp = rhs.fltphp;
    flthp = rhs.flthp;
    flthp_d = rhs.flthp_d;
    vib_phase = rhs.vib_phase;
    vib_speed = rhs.vib_speed;
    vib_amp = rhs.vib_amp;
    rep_time = rhs.rep_time;
    rep_limit = rhs.rep_limit;
    arp_time = rhs.arp_time;
    arp_limit = rhs.arp_limit;
    arp_mod = rhs.arp_mod;
    file_sampleswritten = rhs.file_sampleswritten;
    wave_type = rhs.wave_type;
    p_base_freq = rhs.p_base_freq;
    p_freq_limit = rhs.p_freq_limit;
    p_freq_ramp = rhs.p_freq_ramp;
    p_freq_dramp = rhs.p_freq_dramp;
    p_duty = rhs.p_duty;
    p_duty_ramp = rhs.p_duty_ramp;
    p_vib_strength = rhs.p_vib_strength;
    p_vib_speed = rhs.p_vib_speed;
    p_vib_delay = rhs.p_vib_delay;
    p_env_attack = rhs.p_env_attack;
    p_env_sustain = rhs.p_env_sustain;
    p_env_decay = rhs.p_env_decay;
    p_env_punch = rhs.p_env_punch;
    filter_on = rhs.filter_on;
    p_lpf_resonance = rhs.p_lpf_resonance;
    p_lpf_freq = rhs.p_lpf_freq;
    p_lpf_ramp = rhs.p_lpf_ramp;
    p_hpf_freq = rhs.p_hpf_freq;
    p_hpf_ramp = rhs.p_hpf_ramp;
    p_pha_offset = rhs.p_pha_offset;
    p_pha_ramp = rhs.p_pha_ramp;
    p_repeat_speed = rhs.p_repeat_speed;
    p_arp_speed = rhs.p_arp_speed;
    p_arp_mod = rhs.p_arp_mod;

    memcpy(env_length, rhs.env_length, sizeof(env_length));
    memcpy(phaser_buffer, rhs.phaser_buffer, sizeof(phaser_buffer));
    memcpy(noise_buffer, rhs.phaser_buffer, sizeof(noise_buffer));

    return *this;
}

// This is a replacement for the original sfxr callback function.
bool sfxr::operator ()(unsigned char* sampleBuffer, int byteCount)
{
    if (playing_sample && !mute_stream)
    {
        unsigned int l = byteCount/2;
        float fbuf[l];
        memset(fbuf, 0, sizeof(fbuf));
        SynthSample(l, fbuf, NULL);
        while (l--)
        {
            float f = fbuf[l];
            if (f < -1.0) f = -1.0;
            if (f > 1.0) f = 1.0;
            ((sint16*)sampleBuffer)[l] = (sint16)(f * 32767);
        }
        return true;
    }
    memset(sampleBuffer, 0, byteCount);
    return false;
}

bool sfxr::LoadSettings(std::istream& stream)
{
    unsigned int version = 0;
    stream.read(reinterpret_cast<char*>(&version), sizeof(version));
    if(version != fileVersion)
    {
        return false;
    }

    stream.read(reinterpret_cast<char*>(&wave_type), sizeof(wave_type));
    stream.read(reinterpret_cast<char*>(&sound_vol), sizeof(sound_vol));

    stream.read(reinterpret_cast<char*>(&p_base_freq), sizeof(p_base_freq));
    stream.read(reinterpret_cast<char*>(&p_freq_limit), sizeof(p_freq_limit));
    stream.read(reinterpret_cast<char*>(&p_freq_ramp), sizeof(p_freq_ramp));
    stream.read(reinterpret_cast<char*>(&p_freq_dramp), sizeof(p_freq_dramp));
    stream.read(reinterpret_cast<char*>(&p_duty), sizeof(p_duty));
    stream.read(reinterpret_cast<char*>(&p_duty_ramp), sizeof(p_duty_ramp));

    stream.read(reinterpret_cast<char*>(&p_vib_strength), sizeof(p_vib_strength));
    stream.read(reinterpret_cast<char*>(&p_vib_speed), sizeof(p_vib_speed));
    stream.read(reinterpret_cast<char*>(&p_vib_delay), sizeof(p_vib_delay));

    stream.read(reinterpret_cast<char*>(&p_env_attack), sizeof(p_env_attack));
    stream.read(reinterpret_cast<char*>(&p_env_sustain), sizeof(p_env_sustain));
    stream.read(reinterpret_cast<char*>(&p_env_decay), sizeof(p_env_decay));
    stream.read(reinterpret_cast<char*>(&p_env_punch), sizeof(p_env_punch));

    stream.read(reinterpret_cast<char*>(&filter_on), sizeof(filter_on));
    stream.read(reinterpret_cast<char*>(&p_lpf_resonance), sizeof(p_lpf_resonance));
    stream.read(reinterpret_cast<char*>(&p_lpf_freq), sizeof(p_lpf_freq));
    stream.read(reinterpret_cast<char*>(&p_lpf_ramp), sizeof(p_lpf_ramp));
    stream.read(reinterpret_cast<char*>(&p_hpf_freq), sizeof(p_hpf_freq));
    stream.read(reinterpret_cast<char*>(&p_hpf_ramp), sizeof(p_hpf_ramp));

    stream.read(reinterpret_cast<char*>(&p_pha_offset), sizeof(p_pha_offset));
    stream.read(reinterpret_cast<char*>(&p_pha_ramp), sizeof(p_pha_ramp));

    stream.read(reinterpret_cast<char*>(&p_repeat_speed), sizeof(p_repeat_speed));

    stream.read(reinterpret_cast<char*>(&p_arp_speed), sizeof(p_arp_speed));
    stream.read(reinterpret_cast<char*>(&p_arp_mod), sizeof(p_arp_mod));

    return stream.good();
}

bool sfxr::SaveSettings(std::ostream& stream) const
{
    unsigned int version = fileVersion;
    stream.write(reinterpret_cast<const char*>(&version), sizeof(version));

    stream.write(reinterpret_cast<const char*>(&wave_type), sizeof(wave_type));
    stream.write(reinterpret_cast<const char*>(&sound_vol), sizeof(sound_vol));

    stream.write(reinterpret_cast<const char*>(&p_base_freq), sizeof(p_base_freq));
    stream.write(reinterpret_cast<const char*>(&p_freq_limit), sizeof(p_freq_limit));
    stream.write(reinterpret_cast<const char*>(&p_freq_ramp), sizeof(p_freq_ramp));
    stream.write(reinterpret_cast<const char*>(&p_freq_dramp), sizeof(p_freq_dramp));
    stream.write(reinterpret_cast<const char*>(&p_duty), sizeof(p_duty));
    stream.write(reinterpret_cast<const char*>(&p_duty_ramp), sizeof(p_duty_ramp));

    stream.write(reinterpret_cast<const char*>(&p_vib_strength), sizeof(p_vib_strength));
    stream.write(reinterpret_cast<const char*>(&p_vib_speed), sizeof(p_vib_speed));
    stream.write(reinterpret_cast<const char*>(&p_vib_delay), sizeof(p_vib_delay));

    stream.write(reinterpret_cast<const char*>(&p_env_attack), sizeof(p_env_attack));
    stream.write(reinterpret_cast<const char*>(&p_env_sustain), sizeof(p_env_sustain));
    stream.write(reinterpret_cast<const char*>(&p_env_decay), sizeof(p_env_decay));
    stream.write(reinterpret_cast<const char*>(&p_env_punch), sizeof(p_env_punch));

    stream.write(reinterpret_cast<const char*>(&filter_on), sizeof(filter_on));
    stream.write(reinterpret_cast<const char*>(&p_lpf_resonance), sizeof(p_lpf_resonance));
    stream.write(reinterpret_cast<const char*>(&p_lpf_freq), sizeof(p_lpf_freq));
    stream.write(reinterpret_cast<const char*>(&p_lpf_ramp), sizeof(p_lpf_ramp));
    stream.write(reinterpret_cast<const char*>(&p_hpf_freq), sizeof(p_hpf_freq));
    stream.write(reinterpret_cast<const char*>(&p_hpf_ramp), sizeof(p_hpf_ramp));

    stream.write(reinterpret_cast<const char*>(&p_pha_offset), sizeof(p_pha_offset));
    stream.write(reinterpret_cast<const char*>(&p_pha_ramp), sizeof(p_pha_ramp));

    stream.write(reinterpret_cast<const char*>(&p_repeat_speed), sizeof(p_repeat_speed));

    stream.write(reinterpret_cast<const char*>(&p_arp_speed), sizeof(p_arp_speed));
    stream.write(reinterpret_cast<const char*>(&p_arp_mod), sizeof(p_arp_mod));

    return stream.good();
}

bool sfxr::LoadSettings(const char* filename)
{
    FILE* file=fopen(filename, "rb");
    if(!file)
        return false;

    int version=0;
    fread(&version, 1, sizeof(int), file);
    if(version!=100 && version!=101 && version!=102)
        return false;

    fread(&wave_type, 1, sizeof(int), file);

    sound_vol=0.5f;
    if(version==102)
        fread(&sound_vol, 1, sizeof(float), file);

    fread(&p_base_freq, 1, sizeof(float), file);
    fread(&p_freq_limit, 1, sizeof(float), file);
    fread(&p_freq_ramp, 1, sizeof(float), file);
    if(version>=101)
        fread(&p_freq_dramp, 1, sizeof(float), file);
    fread(&p_duty, 1, sizeof(float), file);
    fread(&p_duty_ramp, 1, sizeof(float), file);

    fread(&p_vib_strength, 1, sizeof(float), file);
    fread(&p_vib_speed, 1, sizeof(float), file);
    fread(&p_vib_delay, 1, sizeof(float), file);

    fread(&p_env_attack, 1, sizeof(float), file);
    fread(&p_env_sustain, 1, sizeof(float), file);
    fread(&p_env_decay, 1, sizeof(float), file);
    fread(&p_env_punch, 1, sizeof(float), file);

    fread(&filter_on, 1, sizeof(bool), file);
    fread(&p_lpf_resonance, 1, sizeof(float), file);
    fread(&p_lpf_freq, 1, sizeof(float), file);
    fread(&p_lpf_ramp, 1, sizeof(float), file);
    fread(&p_hpf_freq, 1, sizeof(float), file);
    fread(&p_hpf_ramp, 1, sizeof(float), file);

    fread(&p_pha_offset, 1, sizeof(float), file);
    fread(&p_pha_ramp, 1, sizeof(float), file);

    fread(&p_repeat_speed, 1, sizeof(float), file);

    if(version>=101)
    {
        fread(&p_arp_speed, 1, sizeof(float), file);
        fread(&p_arp_mod, 1, sizeof(float), file);
    }

    fclose(file);
    return true;
}

bool sfxr::SaveSettings(const char* filename)
{
    FILE* file=fopen(filename, "wb");
    if(!file)
        return false;

    int version=102;
    fwrite(&version, 1, sizeof(int), file);

    fwrite(&wave_type, 1, sizeof(int), file);

    fwrite(&sound_vol, 1, sizeof(float), file);

    fwrite(&p_base_freq, 1, sizeof(float), file);
    fwrite(&p_freq_limit, 1, sizeof(float), file);
    fwrite(&p_freq_ramp, 1, sizeof(float), file);
    fwrite(&p_freq_dramp, 1, sizeof(float), file);
    fwrite(&p_duty, 1, sizeof(float), file);
    fwrite(&p_duty_ramp, 1, sizeof(float), file);

    fwrite(&p_vib_strength, 1, sizeof(float), file);
    fwrite(&p_vib_speed, 1, sizeof(float), file);
    fwrite(&p_vib_delay, 1, sizeof(float), file);

    fwrite(&p_env_attack, 1, sizeof(float), file);
    fwrite(&p_env_sustain, 1, sizeof(float), file);
    fwrite(&p_env_decay, 1, sizeof(float), file);
    fwrite(&p_env_punch, 1, sizeof(float), file);

    fwrite(&filter_on, 1, sizeof(bool), file);
    fwrite(&p_lpf_resonance, 1, sizeof(float), file);
    fwrite(&p_lpf_freq, 1, sizeof(float), file);
    fwrite(&p_lpf_ramp, 1, sizeof(float), file);
    fwrite(&p_hpf_freq, 1, sizeof(float), file);
    fwrite(&p_hpf_ramp, 1, sizeof(float), file);

    fwrite(&p_pha_offset, 1, sizeof(float), file);
    fwrite(&p_pha_ramp, 1, sizeof(float), file);

    fwrite(&p_repeat_speed, 1, sizeof(float), file);

    fwrite(&p_arp_speed, 1, sizeof(float), file);
    fwrite(&p_arp_mod, 1, sizeof(float), file);

    fclose(file);
    return true;
}

bool sfxr::ExportWAV(const char* filename)
{
    FILE* foutput=fopen(filename, "wb");
    if(!foutput)
        return false;
    // write wav header
    unsigned int dword=0;
    unsigned short word=0;
    fwrite("RIFF", 4, 1, foutput); // "RIFF"
    dword=0;
    fwrite(&dword, 1, 4, foutput); // remaining file size
    fwrite("WAVE", 4, 1, foutput); // "WAVE"

    fwrite("fmt ", 4, 1, foutput); // "fmt "
    dword=16;
    fwrite(&dword, 1, 4, foutput); // chunk size
    word=1;
    fwrite(&word, 1, 2, foutput); // compression code
    word=1;
    fwrite(&word, 1, 2, foutput); // channels
    dword=wav_freq;
    fwrite(&dword, 1, 4, foutput); // sample rate
    dword=wav_freq*wav_bits/8;
    fwrite(&dword, 1, 4, foutput); // bytes/sec
    word=wav_bits/8;
    fwrite(&word, 1, 2, foutput); // block align
    word=wav_bits;
    fwrite(&word, 1, 2, foutput); // bits per sample

    fwrite("data", 4, 1, foutput); // "data"
    dword=0;
    int foutstream_datasize=ftell(foutput);
    fwrite(&dword, 1, 4, foutput); // chunk size

    // write sample data
    mute_stream=true;
    file_sampleswritten=0;
    filesample=0.0f;
    fileacc=0;
    PlaySample();
    while(playing_sample)
        SynthSample(256, NULL, foutput);
    mute_stream=false;


    // seek back to header and write size info
    fseek(foutput, 4, SEEK_SET);
    dword=0;
    dword=foutstream_datasize-4+file_sampleswritten*wav_bits/8;
    fwrite(&dword, 1, 4, foutput); // remaining file size
    fseek(foutput, foutstream_datasize, SEEK_SET);
    dword=file_sampleswritten*wav_bits/8;
    fwrite(&dword, 1, 4, foutput); // chunk size (data)
    fclose(foutput);

    return true;
}

void sfxr::ResetParams()
{
	wave_type=0;

	p_base_freq=0.3f;
	p_freq_limit=0.0f;
	p_freq_ramp=0.0f;
	p_freq_dramp=0.0f;
	p_duty=0.0f;
	p_duty_ramp=0.0f;

	p_vib_strength=0.0f;
	p_vib_speed=0.0f;
	p_vib_delay=0.0f;

	p_env_attack=0.0f;
	p_env_sustain=0.3f;
	p_env_decay=0.4f;
	p_env_punch=0.0f;

	filter_on=false;
	p_lpf_resonance=0.0f;
	p_lpf_freq=1.0f;
	p_lpf_ramp=0.0f;
	p_hpf_freq=0.0f;
	p_hpf_ramp=0.0f;
	
	p_pha_offset=0.0f;
	p_pha_ramp=0.0f;

	p_repeat_speed=0.0f;

	p_arp_speed=0.0f;
	p_arp_mod=0.0f;
}

void sfxr::ResetSample(bool restart)
{
	if(!restart)
		phase=0;
	fperiod=100.0/(p_base_freq*p_base_freq+0.001);
	period=(int)fperiod;
	fmaxperiod=100.0/(p_freq_limit*p_freq_limit+0.001);
	fslide=1.0-pow((double)p_freq_ramp, 3.0)*0.01;
	fdslide=-pow((double)p_freq_dramp, 3.0)*0.000001;
	square_duty=0.5f-p_duty*0.5f;
	square_slide=-p_duty_ramp*0.00005f;
	if(p_arp_mod>=0.0f)
		arp_mod=1.0-pow((double)p_arp_mod, 2.0)*0.9;
	else
		arp_mod=1.0+pow((double)p_arp_mod, 2.0)*10.0;
	arp_time=0;
	arp_limit=(int)(pow(1.0f-p_arp_speed, 2.0f)*20000+32);
	if(p_arp_speed==1.0f)
		arp_limit=0;
	if(!restart)
	{
		// reset filter
		fltp=0.0f;
		fltdp=0.0f;
		fltw=pow(p_lpf_freq, 3.0f)*0.1f;
		fltw_d=1.0f+p_lpf_ramp*0.0001f;
		fltdmp=5.0f/(1.0f+pow(p_lpf_resonance, 2.0f)*20.0f)*(0.01f+fltw);
		if(fltdmp>0.8f) fltdmp=0.8f;
		fltphp=0.0f;
		flthp=pow(p_hpf_freq, 2.0f)*0.1f;
		flthp_d=1.0+p_hpf_ramp*0.0003f;
		// reset vibrato
		vib_phase=0.0f;
		vib_speed=pow(p_vib_speed, 2.0f)*0.01f;
		vib_amp=p_vib_strength*0.5f;
		// reset envelope
		env_vol=0.0f;
		env_stage=0;
		env_time=0;
		env_length[0]=(int)(p_env_attack*p_env_attack*100000.0f);
		env_length[1]=(int)(p_env_sustain*p_env_sustain*100000.0f);
		env_length[2]=(int)(p_env_decay*p_env_decay*100000.0f);

		fphase=pow(p_pha_offset, 2.0f)*1020.0f;
		if(p_pha_offset<0.0f) fphase=-fphase;
		fdphase=pow(p_pha_ramp, 2.0f)*1.0f;
		if(p_pha_ramp<0.0f) fdphase=-fdphase;
		iphase=abs((int)fphase);
		ipp=0;
		for(int i=0;i<1024;i++)
			phaser_buffer[i]=0.0f;

		for(int i=0;i<32;i++)
			noise_buffer[i] = frnd(2.0f) - 1.0f;

		rep_time=0;
		rep_limit=(int)(pow(1.0f-p_repeat_speed, 2.0f)*20000+32);
		if(p_repeat_speed==0.0f)
			rep_limit=0;
	}
}

void sfxr::PlaySample()
{
	ResetSample(false);
	playing_sample=true;
}

void sfxr::SynthSample(int length, float* buffer, FILE* file)
{
	for(int i=0;i<length;i++)
	{
		if(!playing_sample)
			break;

		rep_time++;
		if(rep_limit!=0 && rep_time>=rep_limit)
		{
			rep_time=0;
			ResetSample(true);
		}

		// frequency envelopes/arpeggios
		arp_time++;
		if(arp_limit!=0 && arp_time>=arp_limit)
		{
			arp_limit=0;
			fperiod*=arp_mod;
		}
		fslide+=fdslide;
		fperiod*=fslide;
		if(fperiod>fmaxperiod)
		{
			fperiod=fmaxperiod;
			if(p_freq_limit>0.0f)
				playing_sample=false;
		}
		float rfperiod=fperiod;
		if(vib_amp>0.0f)
		{
			vib_phase+=vib_speed;
			rfperiod=fperiod*(1.0+sin(vib_phase)*vib_amp);
		}
		period=(int)rfperiod;
		if(period<8) period=8;
		square_duty+=square_slide;
		if(square_duty<0.0f) square_duty=0.0f;
		if(square_duty>0.5f) square_duty=0.5f;		
		// volume envelope
		env_time++;
		if(env_time>env_length[env_stage])
		{
			env_time=0;
			env_stage++;
			if(env_stage==3)
				playing_sample=false;
		}
		if(env_stage==0)
			env_vol=(float)env_time/env_length[0];
		if(env_stage==1)
			env_vol=1.0f+pow(1.0f-(float)env_time/env_length[1], 1.0f)*2.0f*p_env_punch;
		if(env_stage==2)
			env_vol=1.0f-(float)env_time/env_length[2];

		// phaser step
		fphase+=fdphase;
		iphase=abs((int)fphase);
		if(iphase>1023) iphase=1023;

		if(flthp_d!=0.0f)
		{
			flthp*=flthp_d;
			if(flthp<0.00001f) flthp=0.00001f;
			if(flthp>0.1f) flthp=0.1f;
		}

		float ssample=0.0f;
		for(int si=0;si<8;si++) // 8x supersampling
		{
			float sample=0.0f;
			phase++;
			if(phase>=period)
			{
//				phase=0;
				phase%=period;
				if(wave_type==3)
					for(int i=0;i<32;i++)
						noise_buffer[i]=frnd(2.0f)-1.0f;
			}
			// base waveform
			float fp=(float)phase/period;
			switch(wave_type)
			{
			case 0: // square
				if(fp<square_duty)
					sample=0.5f;
				else
					sample=-0.5f;
				break;
			case 1: // sawtooth
				sample=1.0f-fp*2;
				break;
			case 2: // sine
				sample=(float)sin(fp*2*PI);
				break;
			case 3: // noise
				sample=noise_buffer[phase*32/period];
				break;
			}
			// lp filter
			float pp=fltp;
			fltw*=fltw_d;
			if(fltw<0.0f) fltw=0.0f;
			if(fltw>0.1f) fltw=0.1f;
			if(p_lpf_freq!=1.0f)
			{
				fltdp+=(sample-fltp)*fltw;
				fltdp-=fltdp*fltdmp;
			}
			else
			{
				fltp=sample;
				fltdp=0.0f;
			}
			fltp+=fltdp;
			// hp filter
			fltphp+=fltp-pp;
			fltphp-=fltphp*flthp;
			sample=fltphp;
			// phaser
			phaser_buffer[ipp&1023]=sample;
			sample+=phaser_buffer[(ipp-iphase+1024)&1023];
			ipp=(ipp+1)&1023;
			// final accumulation and envelope application
			ssample+=sample*env_vol;
		}
		ssample=ssample/8*master_vol;

		ssample*=2.0f*sound_vol;

		if(buffer!=NULL)
		{
			if(ssample>1.0f) ssample=1.0f;
			if(ssample<-1.0f) ssample=-1.0f;
			*buffer++=ssample;
		}
		if(file!=NULL)
		{
			// quantize depending on format
			// accumulate/count to accomodate variable sample rate?
			ssample*=4.0f; // arbitrary gain to get reasonable output volume...
			if(ssample>1.0f) ssample=1.0f;
			if(ssample<-1.0f) ssample=-1.0f;
			filesample+=ssample;
			fileacc++;
			if(wav_freq==44100 || fileacc==2)
			{
				filesample/=fileacc;
				fileacc=0;
				if(wav_bits==16)
				{
					short isample=(short)(filesample*32000);
					fwrite(&isample, 1, 2, file);
				}
				else
				{
					unsigned char isample=(unsigned char)(filesample*127+128);
					fwrite(&isample, 1, 1, file);
				}
				filesample=0.0f;
			}
			file_sampleswritten++;
		}
	}
}

float sfxr::GetSoundVolume() const
{
    return sound_vol;
}

void sfxr::SetSoundVolume(const float value)
{
    sound_vol = value;
}

WaveformGenerator sfxr::GetWaveform() const
{
    switch (wave_type) {
        case 0:
            return SquareWave;
        case 1:
            return Sawtooth;
        case 2:
            return SineWave;
        case 3:
            return Noise;
        default:
            abort();
    }
}

void sfxr::SetWaveform(const WaveformGenerator waveform)
{
    switch (waveform) {
        case SquareWave:
            wave_type = 0;
            break;
        case Sawtooth:
            wave_type = 1;
            break;
        case SineWave:
            wave_type = 2;
            break;
        case Noise:
            wave_type = 3;
            break;
        default:
            abort();
    }
}

float sfxr::GetAttackTime() const
{
    return p_env_attack;
}

void sfxr::SetAttackTime(const float value)
{
    p_env_attack = value;
}

float sfxr::GetSustainTime() const
{
    return p_env_sustain;
}

void sfxr::SetSustainTime(const float value)
{
    p_env_sustain = value;
}

float sfxr::GetSustainPunch() const
{
    return p_env_punch;
}

void sfxr::SetSustainPunch(const float value)
{
    p_env_punch = value;
}

float sfxr::GetDecayTime() const
{
    return p_env_decay;
}

void sfxr::SetDecayTime(const float value)
{
    p_env_decay = value;
}

float sfxr::GetStartFrequency() const
{
    return p_base_freq;
}

void sfxr::SetStartFrequency(const float value)
{
    p_base_freq = value;
}

float sfxr::GetMinimumFrequency() const
{
    return p_freq_limit;
}

void sfxr::SetMinimumFrequency(const float value)
{
    p_freq_limit = value;
}

float sfxr::GetSlide() const
{
    return (p_freq_ramp + 1.0f) * 0.5f;
}

void sfxr::SetSlide(const float value)
{
    p_freq_ramp = value * 2.0f - 1.0f;
}

float sfxr::GetDeltaSlide() const
{
    return (p_vib_strength + 1.0f) * 0.5f;
}

void sfxr::SetDeltaSlide(const float value)
{
    p_vib_strength = value * 2.0f - 1.0f;
}

float sfxr::GetVibratoDepth() const
{
    return p_vib_strength;
}

void sfxr::SetVibratoDepth(const float value)
{
    p_vib_strength = value;
}

float sfxr::GetVibratoSpeed() const
{
    return p_vib_speed;
}

void sfxr::SetVibratoSpeed(const float value)
{
    p_vib_speed = value;
}

float sfxr::GetChangeAmount() const
{
    return (p_arp_mod + 1.0f) * 0.5f;
}

void sfxr::SetChangeAmount(const float value)
{
    p_arp_mod = value * 2.0f - 1.0f;
}

float sfxr::GetChangeSpeed() const
{
    return p_arp_speed;
}

void sfxr::SetChangeSpeed(const float value)
{
    p_arp_speed = value;
}

float sfxr::GetSquareDuty() const
{
    return p_duty;
}

void sfxr::SetSquareDuty(const float value)
{
    p_duty = value;
}

float sfxr::GetDutySweep() const
{
    return (p_duty_ramp + 1.0f) * 0.5f;
}

void sfxr::SetDutySweep(const float value)
{
    p_duty_ramp = value * 2.0f + 1.0f;
}

float sfxr::GetRepeatSpeed() const
{
    return p_repeat_speed;
}

void sfxr::SetRepeatSpeed(const float value)
{
    p_repeat_speed = value;
}

float sfxr::GetPhaserOffset() const
{
    return (p_pha_offset + 1.0f) * 0.5f;
}

void sfxr::SetPhaserOffset(const float value)
{
    p_pha_offset = value * 2.0f + 1.0f;
}

float sfxr::GetPhaserSweep() const
{
    return (p_pha_ramp + 1.0f) * 0.5f;
}

void sfxr::SetPhaserSweep(const float value)
{
    p_pha_ramp = value * 2.0f + 1.0f;
}

float sfxr::GetLowPassFilterCutoff() const
{
    return p_lpf_freq;
}

void sfxr::SetLowPassFilterCutoff(const float value)
{
    p_lpf_freq = value;
}

float sfxr::GetLowPassFilterCutoffSweep() const
{
    return (p_lpf_ramp + 1.0f) * 0.5f;
}

void sfxr::SetLowPassFilterCutoffSweep(const float value)
{
    p_lpf_ramp = value * 2.0f + 1.0f;
}

float sfxr::GetLowPassFilterResonance() const
{
    return p_lpf_resonance;
}

void sfxr::SetLowPassFilterResonance(const float value)
{
    p_lpf_resonance = value;
}

float sfxr::GetHighPassFilterCutoff() const
{
    return p_hpf_freq;
}

void sfxr::SetHighPassFilterCutoff(const float value)
{
    p_hpf_freq = value;
}

float sfxr::GetHighPassFilterCutoffSweep() const
{
    return (p_hpf_ramp + 1.0f) * 0.5f;
}

void sfxr::SetHighPassFilterCutoffSweep(const float value)
{
    p_hpf_ramp = value * 2.0f + 1.0f;
}

void sfxr::PickupCoinButtonPressed()
{
    ResetParams();
    p_base_freq=0.4f+frnd(0.5f);
    p_env_attack=0.0f;
    p_env_sustain=frnd(0.1f);
    p_env_decay=0.1f+frnd(0.4f);
    p_env_punch=0.3f+frnd(0.3f);
    if(rnd(1))
    {
        p_arp_speed=0.5f+frnd(0.2f);
        p_arp_mod=0.2f+frnd(0.4f);
    }
    PlaySample();
}

void sfxr::LaserShootButtonPressed()
{
    ResetParams();
    wave_type=rnd(2);
    if(wave_type==2 && rnd(1))
        wave_type=rnd(1);
    p_base_freq=0.5f+frnd(0.5f);
    p_freq_limit=p_base_freq-0.2f-frnd(0.6f);
    if(p_freq_limit<0.2f) p_freq_limit=0.2f;
    p_freq_ramp=-0.15f-frnd(0.2f);
    if(rnd(2)==0)
    {
        p_base_freq=0.3f+frnd(0.6f);
        p_freq_limit=frnd(0.1f);
        p_freq_ramp=-0.35f-frnd(0.3f);
    }
    if(rnd(1))
    {
        p_duty=frnd(0.5f);
        p_duty_ramp=frnd(0.2f);
    }
    else
    {
        p_duty=0.4f+frnd(0.5f);
        p_duty_ramp=-frnd(0.7f);
    }
    p_env_attack=0.0f;
    p_env_sustain=0.1f+frnd(0.2f);
    p_env_decay=frnd(0.4f);
    if(rnd(1))
        p_env_punch=frnd(0.3f);
    if(rnd(2)==0)
    {
        p_pha_offset=frnd(0.2f);
        p_pha_ramp=-frnd(0.2f);
    }
    if(rnd(1))
        p_hpf_freq=frnd(0.3f);
    PlaySample();
}

void sfxr::ExplosionButtonPressed()
{
    ResetParams();
    wave_type=3;
    if(rnd(1))
    {
        p_base_freq=0.1f+frnd(0.4f);
        p_freq_ramp=-0.1f+frnd(0.4f);
    }
    else
    {
        p_base_freq=0.2f+frnd(0.7f);
        p_freq_ramp=-0.2f-frnd(0.2f);
    }
    p_base_freq*=p_base_freq;
    if(rnd(4)==0)
        p_freq_ramp=0.0f;
    if(rnd(2)==0)
        p_repeat_speed=0.3f+frnd(0.5f);
    p_env_attack=0.0f;
    p_env_sustain=0.1f+frnd(0.3f);
    p_env_decay=frnd(0.5f);
    if(rnd(1)==0)
    {
        p_pha_offset=-0.3f+frnd(0.9f);
        p_pha_ramp=-frnd(0.3f);
    }
    p_env_punch=0.2f+frnd(0.6f);
    if(rnd(1))
    {
        p_vib_strength=frnd(0.7f);
        p_vib_speed=frnd(0.6f);
    }
    if(rnd(2)==0)
    {
        p_arp_speed=0.6f+frnd(0.3f);
        p_arp_mod=0.8f-frnd(1.6f);
    }
    PlaySample();
}

void sfxr::PowerupButtonPressed()
{
    ResetParams();
    if(rnd(1))
        wave_type=1;
    else
        p_duty=frnd(0.6f);
    if(rnd(1))
    {
        p_base_freq=0.2f+frnd(0.3f);
        p_freq_ramp=0.1f+frnd(0.4f);
        p_repeat_speed=0.4f+frnd(0.4f);
    }
    else
    {
        p_base_freq=0.2f+frnd(0.3f);
        p_freq_ramp=0.05f+frnd(0.2f);
        if(rnd(1))
        {
            p_vib_strength=frnd(0.7f);
            p_vib_speed=frnd(0.6f);
        }
    }
    p_env_attack=0.0f;
    p_env_sustain=frnd(0.4f);
    p_env_decay=0.1f+frnd(0.4f);
    PlaySample();
}

void sfxr::HitHurtButtonPressed()
{
    ResetParams();
    wave_type=rnd(2);
    if(wave_type==2)
        wave_type=3;
    if(wave_type==0)
        p_duty=frnd(0.6f);
    p_base_freq=0.2f+frnd(0.6f);
    p_freq_ramp=-0.3f-frnd(0.4f);
    p_env_attack=0.0f;
    p_env_sustain=frnd(0.1f);
    p_env_decay=0.1f+frnd(0.2f);
    if(rnd(1))
        p_hpf_freq=frnd(0.3f);
    PlaySample();
}

void sfxr::JumpButtonPressed()
{
    ResetParams();
    wave_type=0;
    p_duty=frnd(0.6f);
    p_base_freq=0.3f+frnd(0.3f);
    p_freq_ramp=0.1f+frnd(0.2f);
    p_env_attack=0.0f;
    p_env_sustain=0.1f+frnd(0.3f);
    p_env_decay=0.1f+frnd(0.2f);
    if(rnd(1))
        p_hpf_freq=frnd(0.3f);
    if(rnd(1))
        p_lpf_freq=1.0f-frnd(0.6f);
    PlaySample();
}

void sfxr::BlitSelectButtonPressed()
{
    ResetParams();
    wave_type=rnd(1);
    if(wave_type==0)
        p_duty=frnd(0.6f);
    p_base_freq=0.2f+frnd(0.4f);
    p_env_attack=0.0f;
    p_env_sustain=0.1f+frnd(0.1f);
    p_env_decay=frnd(0.2f);
    p_hpf_freq=0.1f;
    PlaySample();
}

void sfxr::MutateButtonPressed()
{
    if(rnd(1)) p_base_freq+=frnd(0.1f)-0.05f;
    //if(rnd(1)) p_freq_limit+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_freq_ramp+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_freq_dramp+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_duty+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_duty_ramp+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_vib_strength+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_vib_speed+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_vib_delay+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_env_attack+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_env_sustain+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_env_decay+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_env_punch+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_lpf_resonance+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_lpf_freq+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_lpf_ramp+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_hpf_freq+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_hpf_ramp+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_pha_offset+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_pha_ramp+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_repeat_speed+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_arp_speed+=frnd(0.1f)-0.05f;
    if(rnd(1)) p_arp_mod+=frnd(0.1f)-0.05f;
    PlaySample();
}

void sfxr::RandomizeButtonPressed()
{
    p_base_freq=pow(frnd(2.0f)-1.0f, 2.0f);
    if(rnd(1))
        p_base_freq=pow(frnd(2.0f)-1.0f, 3.0f)+0.5f;
    p_freq_limit=0.0f;
    p_freq_ramp=pow(frnd(2.0f)-1.0f, 5.0f);
    if(p_base_freq>0.7f && p_freq_ramp>0.2f)
        p_freq_ramp=-p_freq_ramp;
    if(p_base_freq<0.2f && p_freq_ramp<-0.05f)
        p_freq_ramp=-p_freq_ramp;
    p_freq_dramp=pow(frnd(2.0f)-1.0f, 3.0f);
    p_duty=frnd(2.0f)-1.0f;
    p_duty_ramp=pow(frnd(2.0f)-1.0f, 3.0f);
    p_vib_strength=pow(frnd(2.0f)-1.0f, 3.0f);
    p_vib_speed=frnd(2.0f)-1.0f;
    p_vib_delay=frnd(2.0f)-1.0f;
    p_env_attack=pow(frnd(2.0f)-1.0f, 3.0f);
    p_env_sustain=pow(frnd(2.0f)-1.0f, 2.0f);
    p_env_decay=frnd(2.0f)-1.0f;
    p_env_punch=pow(frnd(0.8f), 2.0f);
    if(p_env_attack+p_env_sustain+p_env_decay<0.2f)
    {
        p_env_sustain+=0.2f+frnd(0.3f);
        p_env_decay+=0.2f+frnd(0.3f);
    }
    p_lpf_resonance=frnd(2.0f)-1.0f;
    p_lpf_freq=1.0f-pow(frnd(1.0f), 3.0f);
    p_lpf_ramp=pow(frnd(2.0f)-1.0f, 3.0f);
    if(p_lpf_freq<0.1f && p_lpf_ramp<-0.05f)
        p_lpf_ramp=-p_lpf_ramp;
    p_hpf_freq=pow(frnd(1.0f), 5.0f);
    p_hpf_ramp=pow(frnd(2.0f)-1.0f, 5.0f);
    p_pha_offset=pow(frnd(2.0f)-1.0f, 3.0f);
    p_pha_ramp=pow(frnd(2.0f)-1.0f, 3.0f);
    p_repeat_speed=frnd(2.0f)-1.0f;
    p_arp_speed=frnd(2.0f)-1.0f;
    p_arp_mod=frnd(2.0f)-1.0f;
    PlaySample();
}
