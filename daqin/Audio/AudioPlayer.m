//
//  AudioPlayer.m
//  Baixing
//
//  Created by XuMengyi on 14-6-18.
//
//

#import "AudioPlayer.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import "amrFileCodec.h"
#import <AudioToolbox/AudioSession.h>

@interface AudioPlayer() <AVAudioPlayerDelegate>
@property (nonatomic, assign) id<AudioPlayerDelegate> listener;
@property (nonatomic, retain) AVAudioPlayer* player;
@end

static AudioPlayer *_sharedInstance = nil;

@implementation AudioPlayer
+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
 
}

-(BOOL) play:(NSString*)filePath listener:(id<AudioPlayerDelegate>)listener{
    if(!filePath) return NO;
    _listener = listener;

    NSError* err = nil;
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
    // route to speaker
    UInt32 ASRoute = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(ASRoute), &ASRoute);


    NSURL *url = [NSURL fileURLWithPath:filePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _player.delegate = self;
    BOOL success = NO;

    
    if([_player prepareToPlay]){
        success = [_player play];
    }
    return success;
}

-(void) stop{
    if(_player){
        [_player stop];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(_listener){
        [_listener onPlayingFinished];
    }
}
@end
