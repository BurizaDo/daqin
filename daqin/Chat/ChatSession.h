//
//  ChatSession.h
//  daqin
//
//  Created by BurizaDo on 8/11/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChatUser;
@interface ChatSession : NSObject
@property (nonatomic, strong) ChatUser *selfUser;
@property (nonatomic, strong) ChatUser *receiverUser;

@property (nonatomic, copy) NSString*  isChattingPeerId;

+ (instancetype)sharedInstance;
+ (void)sendMessage:(NSString*)content;
- (void) setup;
- (void) enableChat:(ChatUser*)selfUser;

- (void) setDeviceToken:(NSData*)token;
@end
