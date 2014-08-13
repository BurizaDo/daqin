//
//  AudioRecorder.h
//  Baixing
//
//  Created by XuMengyi on 14-6-18.
//
//

#import <Foundation/Foundation.h>
@class AVAudioRecorder;
typedef enum{
    IDLE,
    READY,
    RECORDING,
    ERROR
}RecorderStatus;

@protocol AudioRecordDelegate <NSObject>
-(void) onStatusChanged:(RecorderStatus)status;
-(void) onRecordingFinished:(NSString*)filePath duration:(int)duration;
@end

@interface AudioRecorder : NSObject
+ (instancetype) sharedInstance;

-(BOOL)startRecording:(id<AudioRecordDelegate>)listener;
-(void)finishRecording;
-(float)getPower;

@end
