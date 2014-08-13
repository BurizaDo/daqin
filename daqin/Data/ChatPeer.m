//
//  HJChatPeer.m
//  Baixing
//
//  Created by neoman on 5/22/14.
//
//

#import "ChatPeer.h"

@implementation ChatPeer

+ (NSDictionary *)parseFormat
{
    return @{
             @"enableChat"   : @"enableChat",
             @"expire"    : @"expire",
             @"receiverId" : @"receiverId",
             @"supportFormat" : @"supportFormat",
             @"userId" : @"userId",
             @"anonymousId" : @"anonymousId",
             @"settings" : @"settings",
             @"statusText" : @"statusText"
             };
}

@end
