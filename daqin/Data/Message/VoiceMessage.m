//
//  BXVoiceMessage.m
//  Data
//
//  Created by XuMengyi on 14-6-20.
//  Copyright (c) 2014年 Baixing. All rights reserved.
//

#import "VoiceMessage.h"

@implementation VoiceMessage
- (id)init
{
    self = [super init];
    if (self) {
        self.type = MessageTypeVoice;
    }
    return self;
}

- (void)setContent:(NSString*)content
{
    if (content) {
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.voiceUrl = dic[@"url"];
            self.duration = [dic[@"duration"] intValue];
        }
    }
}

- (NSData*) objectData
{
    if (self.localPath) {
        NSData *dataOfObject = [self.localPath dataUsingEncoding:NSUTF8StringEncoding];
        return dataOfObject;
    }
    else{
        return nil;
    }
}

- (void) loadObject
{
    if (self.object.length>0) {
        NSData *data = self.object;
        if (data) {
            self.localPath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
}

- (NSDictionary*) contentDic
{
    
    NSDictionary* contentDic =  @{@"url":self.voiceUrl,
                                  @"duration":[NSNumber numberWithInt:self.duration]};
    return contentDic;
}

@end
