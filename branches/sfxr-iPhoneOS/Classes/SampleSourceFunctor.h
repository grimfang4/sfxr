/*
 *  SampleSourceFunctor.h
 *  sfxr
 *
 *  Copyright Christopher Gassib 2009.
 *  This file is released under the MIT license as described in readme.txt
 *
 */

struct SampleSourceFunctor
{
    // Fills the passed sample buffer with audio samples, and returns.
    //  sampleBuffer is a byte buffer of signed 16-bit samples.
    //  byteCount is the size _in bytes_ of the sampleBuffer.
    // Returns true if the sample buffer isn't completely silent.
    virtual bool operator ()(unsigned char* sampleBuffer, int byteCount) = 0;
};
