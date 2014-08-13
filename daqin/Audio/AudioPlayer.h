//
//  AudioPlayer.h
//  Baixing
//
//  Created by XuMengyi on 14-6-18.
//
//

#import <Foundation/Foundation.h>
@protocol AudioPlayerDelegate <NSObject>
-(void) onPlayingFinished;
@end

@interface AudioPlayer : NSObject
+ (instancetype) sharedInstance;

-(BOOL) play:(NSString*)filePath listener:(id<AudioPlayerDelegate>)listener;

-(void) stop;

@end
