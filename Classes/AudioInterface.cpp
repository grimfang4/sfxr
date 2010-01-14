/*
 *  AudioInterface.cpp
 *  sfxr
 *
 *  Copyright Christopher Gassib 2009.
 *  This file is released under the MIT license as described in readme.txt
 *
 */

#include "sfxr_Prefix.pch"
#include "SampleSourceFunctor.h"
#include "AudioInterface.h"

const unsigned int AudioInterface::BufferSampleCount = 4096 * 2;
const unsigned int AudioInterface::BufferSize = BufferSampleCount * sizeof(sint16);

AudioInterface::AudioInterface()
: SampleSource(NULL), qEnd(true)
{
    // Do the OpenAL start up.
    alcDevice = alcOpenDevice(NULL); // select the "preferred device"
    if (NULL == alcDevice)
    {
        abort();
    }

    ALCint attrlist[] = {
        ALC_FREQUENCY, 44100,
        ALC_MONO_SOURCES, 1,
        0 };
    alcContext = alcCreateContext(alcDevice, attrlist);
    if (NULL == alcContext)
    {
        abort();
    }
    
    ALCboolean result = alcMakeContextCurrent(alcContext);
    if (ALC_FALSE == result)
    {
        abort();
    }

    alGetError(); // clear error code

    alGenBuffers(2, audioBuffers);
    alGenSources(1, &audioSource);

    int errorCode = pthread_mutex_init(&mutex, NULL);
    if (0 != errorCode)
    {
        abort();
    }
}

AudioInterface::~AudioInterface()
{
    int errorCode = pthread_mutex_destroy(&mutex);
    if (0 != errorCode)
    {
        std::cerr << "Failed to destroy mutex." << std::endl;
    }

    alSourceStop(audioSource);
    EmptySampleQueue();
    alDeleteSources(1, &audioSource);
    alDeleteBuffers(2, audioBuffers);

    alcMakeContextCurrent(NULL);
    alcDestroyContext(alcContext);
    alcCloseDevice(alcDevice);
}

// This clears the audio buffer queue.
void AudioInterface::EmptySampleQueue()
{
    ALint queued;
    alGetSourcei(audioSource, AL_BUFFERS_QUEUED, &queued);

    while(queued--)
    {
        ALuint buffer;
        alSourceUnqueueBuffers(audioSource, 1, &buffer);
    }
}

// This checks if the audio is currently playing.
bool AudioInterface::IsPlaying()
{
    ALenum state;
    alGetSourcei(audioSource, AL_SOURCE_STATE, &state);
    return (state == AL_PLAYING);
}

// This fills the audio buffers and starts them playing.
bool AudioInterface::Playback()
{
    if (!qEnd)
    {
        return false;
    }

    if(IsPlaying())
    {
        return true;
    }

    //alSourceStop(audioSource);
    EmptySampleQueue();

    if (!Stream(audioBuffers[0]))
        return false;

    Stream(audioBuffers[1]);
    
    alSourceQueueBuffers(audioSource, 2, audioBuffers);
    alSourcePlay(audioSource);

    qEnd = false;

    return true;
}

// This reads samples from the source.
bool AudioInterface::Stream(ALuint buffer)
{
    unsigned char data[BufferSize];

    bool isSamples = false;

    int errorCode = pthread_mutex_lock(&mutex);
    if (0 != errorCode)
    {
        std::cerr << "Failed to lock mutex." << std::endl;
    }
    {
        if (NULL != SampleSource)
        {
            SampleSourceFunctor& FillDataBuffer = *SampleSource;
            isSamples = FillDataBuffer(data, BufferSize);
        }
        else
        {
            memset(data, 0, sizeof(data));
        }
    }
    errorCode = pthread_mutex_unlock(&mutex);
    if (0 != errorCode)
    {
        std::cerr << "Failed to unlock mutex." << std::endl;
    }

    alBufferData(buffer, AL_FORMAT_MONO16, data, BufferSize, 44100);

    return isSamples;
}

// This streams samples in and swaps them into audio buffers.
bool AudioInterface::StreamUpdate()
{
    if (qEnd)
    {
        return false;
    }

    ALint processed;
    alGetSourcei(audioSource, AL_BUFFERS_PROCESSED, &processed);

    bool streaming = false;
    while(processed--)
    {
        ALuint buffer;
        alSourceUnqueueBuffers(audioSource, 1, &buffer);

        bool isStreamPlaying = Stream(buffer);
        streaming |= isStreamPlaying;

        alSourceQueueBuffers(audioSource, 1, &buffer);
        
        if (!isStreamPlaying)
        {
            qEnd = true;
        }
    }

    return streaming;
}

void AudioInterface::SetSampleSource(SampleSourceFunctor* sampleSourceFunctor)
{
    int errorCode = pthread_mutex_lock(&mutex);
    if (0 != errorCode)
    {
        std::cerr << "Failed to lock mutex." << std::endl;
    }
    {
        SampleSource = sampleSourceFunctor;
    }
    errorCode = pthread_mutex_unlock(&mutex);
    if (0 != errorCode)
    {
        std::cerr << "Failed to unlock mutex." << std::endl;
    }
}

// This pumps samples for playback and starts the playing if it's not already.
void AudioInterface::Update()
{
    StreamUpdate();
    Playback();
}
