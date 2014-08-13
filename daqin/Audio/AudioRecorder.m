//
//  AudioRecorder.m
//  Baixing
//
//  Created by XuMengyi on 14-6-18.
//
//

#import "AudioRecorder.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>
//#include <opencore-amrnb/interf_enc.h>
#import "amrFileCodec.h"

@interface AudioRecorder() <AVAudioRecorderDelegate>
@property(nonatomic, retain) AVAudioRecorder* recorder;
@property(nonatomic, retain) NSString* currentAudioPath;
@property(nonatomic, assign) id<AudioRecordDelegate> listener;
@property(nonatomic, assign) long duration;
@end

static AudioRecorder *_sharedInstance = nil;
@implementation AudioRecorder
+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(BOOL)startRecording:(id<AudioRecordDelegate>)listener{
    _listener = listener;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* soundsDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@"Sounds"];
    [[NSFileManager defaultManager] createDirectoryAtPath:soundsDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    _currentAudioPath = [soundsDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%d.wav", (int)[[NSDate date] timeIntervalSince1970]]];
    
    NSURL *url = [NSURL fileURLWithPath:_currentAudioPath];
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
//                                    [NSNumber numberWithInt: kAudioFormatAMR], AVFormatIDKey,
                                    [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                                    nil];

    NSError* error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    self.recorder.delegate = self;
    
    BOOL success = NO;
    if([self.recorder prepareToRecord]){
        NSError *err = nil;
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
        
        // route to speaker
        UInt32 ASRoute = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(ASRoute), &ASRoute);
        
        [audioSession setActive:YES error:&err];
        _recorder.meteringEnabled = YES;
        success = [self.recorder record];
        _duration = [[NSDate date] timeIntervalSince1970];
    }else{
        self.recorder = nil;
    }
    return success;
}

-(void)finishRecording{
    if(self.recorder){
        [self.recorder stop];
        self.recorder = nil;
    }
}

-(float)getPower{
    [_recorder updateMeters];    
    NSLog(@"power:%f", [_recorder peakPowerForChannel:0]);

    if(_recorder){

        return pow(10, (0.05 * [_recorder peakPowerForChannel:0]));;
    }
    return 0;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    _duration = [[NSDate date] timeIntervalSince1970] - _duration;
    if(_duration < 1){
        if(_listener){
            [_listener onRecordingFinished:nil duration:_duration];
        }
        return;
    }
    NSString* outPath = [NSString stringWithString:_currentAudioPath];
    outPath = [outPath substringToIndex:(outPath.length - 3)];
    outPath = [outPath stringByAppendingString:@"amr"];
    EncodeWAVEFileToAMRFile([_currentAudioPath UTF8String], [outPath UTF8String], 1, 8);
//    encodeToAMR([_currentAudioPath UTF8String], [outPath UTF8String]);
    if(_listener){
        [_listener onRecordingFinished:outPath duration:_duration];
    }
    _duration = 0;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    
}

@end
