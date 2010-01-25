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

const unsigned int AudioInterface::BufferSampleCount = 4096 * 1;
const unsigned int AudioInterface::BufferSize = BufferSampleCount * sizeof(sint16);
const unsigned int AudioInterface::BufferCount = 2;

alBufferDataStaticProcPtr AudioInterface::alBufferDataStatic = NULL;

AudioInterface::AudioInterface()
: SampleSource(NULL), qEnd(true)
{
    // Allocate memory for this application's sample buffers.
    staticSampleBuffers.resize(BufferCount);
    for (unsigned int i = 0; i < BufferCount; i++)
    {
        staticSampleBuffers[i].resize(BufferSize);
    }

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

    audioBuffers.resize(BufferCount);
    alGenBuffers(BufferCount, &audioBuffers[0]);
    alGenSources(1, &audioSource);

    int errorCode = pthread_mutex_init(&mutex, NULL);
    if (0 != errorCode)
    {
        abort();
    }

    // Try to get a hold of the iPhone OpenAL extension(s).
    if (NULL == alBufferDataStatic)
    {
        alBufferDataStatic =
            reinterpret_cast<alBufferDataStaticProcPtr>(alGetProcAddress("alBufferDataStatic"));
        if (NULL == alBufferDataStatic) // if (we didn't get the extension)
        {
            alBufferDataStatic = &AudioInterface::myBufferDataStatic; // link to our fallback function
        }
    }
    
    // Start up code:
    EmptySampleQueue();

    for (unsigned int i = 0; i < BufferCount; i++)
    {
        Stream(audioBuffers[i]);
    }

    alSourceQueueBuffers(audioSource, BufferCount, &audioBuffers[0]);
    alSourcePlay(audioSource);
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
    alDeleteBuffers(BufferCount, &audioBuffers[0]);

    alcMakeContextCurrent(NULL);
    alcDestroyContext(alcContext);
    alcCloseDevice(alcDevice);
    
    audioBuffers.clear();
    staticSampleBuffers.clear();
}

ALvoid AL_APIENTRY AudioInterface::myBufferDataStatic(const ALint bid, ALenum format, ALvoid* data,
    ALsizei size, ALsizei freq)
{
    alBufferData(bid, format, data, size, freq);
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

// This checks if the audio play back has stopped.
bool AudioInterface::IsStopped()
{
    ALenum state;
    alGetSourcei(audioSource, AL_SOURCE_STATE, &state);
    return (AL_STOPPED == state);
}

// This reads samples from the source.
bool AudioInterface::Stream(ALuint buffer)
{
    // Figure out which static sample buffer to fill.
    unsigned int bufferIndex = 0;
    for (unsigned int i = 0; i < BufferCount; i++)
    {
        if (audioBuffers[i] == buffer)
        {
            bufferIndex = i;
            break;
        }
    }

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
            isSamples = FillDataBuffer(&(staticSampleBuffers[bufferIndex])[0], BufferSize);
        }
        else
        {
            memset(&(staticSampleBuffers[bufferIndex])[0], 0, staticSampleBuffers[bufferIndex].size());
        }
    }
    errorCode = pthread_mutex_unlock(&mutex);
    if (0 != errorCode)
    {
        std::cerr << "Failed to unlock mutex." << std::endl;
    }

    alBufferDataStatic(buffer, AL_FORMAT_MONO16, &(staticSampleBuffers[bufferIndex])[0], BufferSize, 44100);

    return isSamples;
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
    if(IsStopped())
    {
        alSourcePlay(audioSource);
    }

    // Streams samples in and swaps them into audio buffers.
    ALint processed;
    alGetSourcei(audioSource, AL_BUFFERS_PROCESSED, &processed);

    while(processed--)
    {
        ALuint buffer;
        alSourceUnqueueBuffers(audioSource, 1, &buffer);

        Stream(buffer);

        alSourceQueueBuffers(audioSource, 1, &buffer);
    }
}
