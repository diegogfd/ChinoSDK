//
//  MPPJackReader.m
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/17/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MPPJackReader.h"

#define AUDIO_DATA_TYPE_FORMAT NSInteger

@implementation MPPJackReader

void *refToSelf;

void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs) {
    
    RecordState * recordState = (RecordState*)inUserData;
    
    AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
    
    MPPJackReader *rec = (__bridge MPPJackReader *) refToSelf;
    [rec feedSamplesToEngine:inBuffer->mAudioDataBytesCapacity audioData:inBuffer->mAudioData];
}

- (id)init
{
    self = [super init];
    if (self) {
        refToSelf = (__bridge void *)(self);
    }
    return self;
}

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format {
    format->mSampleRate = 16000.0;
    
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFormatFlags =  kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    format->mFramesPerPacket  = 1;
    format->mChannelsPerFrame = 1;
    format->mBytesPerFrame    = sizeof(Float32);
    format->mBytesPerPacket   = sizeof(Float32);
    format->mBitsPerChannel   = sizeof(Float32) * 8;
}

- (void)startRecording {
    [self setupAudioFormat:&recordState.dataFormat];
    
    recordState.currentPacket = 0;
    
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat,
                                AudioInputCallback,
                                &recordState,
                                CFRunLoopGetCurrent(),
                                kCFRunLoopCommonModes,
                                0,
                                &recordState.queue);
    
    if (status == 0) {
        
        for (int i = 0; i < NUM_BUFFERS; i++) {
            AudioQueueAllocateBuffer(recordState.queue, 256, &recordState.buffers[i]);
            AudioQueueEnqueueBuffer(recordState.queue, recordState.buffers[i], 0, nil);
        }
        
        recordState.recording = true;
        
        status = AudioQueueStart(recordState.queue, NULL);
    }
}

- (void)stopRecording {
    recordState.recording = false;
    
    AudioQueueStop(recordState.queue, true);
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
    }
    
    AudioQueueDispose(recordState.queue, true);
    AudioFileClose(recordState.audioFile);
}

- (void)feedSamplesToEngine:(UInt32)audioDataBytesCapacity audioData:(void *)audioData {
    int sampleCount = audioDataBytesCapacity / sizeof(AUDIO_DATA_TYPE_FORMAT);
    AUDIO_DATA_TYPE_FORMAT *samples = (AUDIO_DATA_TYPE_FORMAT*)audioData;
    
    NSMutableArray<NSNumber *> *samplesArray = [NSMutableArray array];
    for ( int i = 0; i < sampleCount; i++) {
        [samplesArray addObject:@(samples[i])];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(jackReaderDelegateDidReadData:)]) {
        [self.delegate jackReaderDelegateDidReadData:samplesArray];
    }
}

@end