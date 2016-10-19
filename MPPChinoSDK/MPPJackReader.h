//
//  MPPJackReader.h
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/17/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#ifndef SpeechBookWormSwift_AudioRecorder_h
#define SpeechBookWormSwift_AudioRecorder_h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_BUFFERS 1

typedef struct
{
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         buffers[NUM_BUFFERS];
    AudioFileID                 audioFile;
    SInt64                      currentPacket;
    bool                        recording;
}RecordState;

void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs);

@protocol MPPJackReaderDelegate <NSObject>
-(void)jackReaderDelegateDidReadData:(NSArray<NSNumber *> *)integerArrayData;
@end

@interface MPPJackReader : NSObject {
    RecordState recordState;
}
@property(assign,nonatomic) id<MPPJackReaderDelegate> delegate;
- (void)startRecording;
- (void)stopRecording;
@end

#endif
