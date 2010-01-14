/*
 *  AudioInterface.h
 *  sfxr
 *
 *  Copyright Christopher Gassib 2009.
 *  This file is released under the MIT license as described in readme.txt
 *
 */
 
class AudioInterface
{
private:
    static const unsigned int BufferSampleCount;
    static const unsigned int BufferSize;
    
    SampleSourceFunctor* SampleSource;

    // OpenAL data:
    ALCdevice*  alcDevice;
    ALCcontext* alcContext;
    ALuint audioBuffers[2]; // front and back buffers
    ALuint audioSource;     // audio source
    bool qEnd;
    pthread_mutex_t mutex;

    // OpenAL audio code:
    void EmptySampleQueue();
    bool IsPlaying();
    bool Playback();
    bool Stream(ALuint buffer);
    bool StreamUpdate();

public:
    AudioInterface();
    virtual ~AudioInterface();
    
    void SetSampleSource(SampleSourceFunctor* sampleSourceFunctor);
    
    void Update();
};
