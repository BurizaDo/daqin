//
//  BXChatUser.m
//  Data
//
//  Created by minjie on 14-5-28.
//  Copyright (c) 2014年 Baixing. All rights reserved.
//

#import "ChatUser.h"

@implementation ChatUser

- (id) initWithPeerId:(NSString*)peerId displayName:(NSString*)displayName iconUrl:(NSString*)iconUrl
{
    self = [super init];
    if (self) {
        self.peerId = peerId;
        self.displayName = displayName;
        self.iconUrl = iconUrl;
    }
    
    return self;
}
@end
