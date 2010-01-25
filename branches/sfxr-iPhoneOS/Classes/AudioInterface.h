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
    static const unsigned int BufferCount;
    
    SampleSourceFunctor* SampleSource;

    // OpenAL data:
    ALCdevice*  alcDevice;
    ALCcontext* alcContext;
    std::vector<ALuint> audioBuffers;   // queue buffers
    ALuint audioSource;                 // audio source
    bool qEnd;
    pthread_mutex_t mutex;

    typedef std::vector<unsigned char> SampleBuffer;
    std::vector<SampleBuffer> staticSampleBuffers;

    // OpenAL audio code:
    void EmptySampleQueue();
    bool IsStopped();
    bool Stream(ALuint buffer);

    // Pointer for the extension function: alBufferDataStatic
    //  see: OpenAL/oalStaticBufferExtension.h
    static alBufferDataStaticProcPtr alBufferDataStatic;

    // This is a fallback function just in case we're unable to make use
    //  of the Apple OpenAL extension: alBufferDataStatic.  Don't call this directly.
    static ALvoid AL_APIENTRY myBufferDataStatic(const ALint bid, ALenum format, ALvoid* data,
        ALsizei size, ALsizei freq);

public:
    AudioInterface();
    virtual ~AudioInterface();
    
    void SetSampleSource(SampleSourceFunctor* sampleSourceFunctor);
    
    void Update();
};
