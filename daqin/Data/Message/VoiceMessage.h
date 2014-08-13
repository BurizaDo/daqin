//
//  BXVoiceMessage.h
//  Data
//
//  Created by XuMengyi on 14-6-20.
//  Copyright (c) 2014年 Baixing. All rights reserved.
//

#import "Message.h"

@interface VoiceMessage : Message
@property(nonatomic,copy) NSString* localPath;
@property(nonatomic,copy) NSString* voiceUrl;
@property(nonatomic,assign) int duration;

@end
