//
//  EventDefinition.h
//  daqin
//
//  Created by BurizaDo on 7/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"
#define kPostSucceed @"kPostSucceed"
#define kNotificationMessageSentAgain       @"kNotificationMessageSentAgain"
#define kCacheUserChatId                    @"kCacheUserChatId"
#define kNotificationNewMessage             @"kNotificationNewMessage" 
#define kNotificationMessageSent            @"kNotificationMessageSent" 
#define kNotificationMessageSentFail        @"kNotificationMessageSentFail"
#define kNotifcationMessageChange                    @"kNotifcationMessageChange" 
#define kNotificationReloadSessionFromDB              @"kNotificationReloadSessionFromDB"
#define kNotificationShouldReloadSession    @"kNotificationShouldReloadSession"
#define kNotificationMessageSent            @"kNotificationMessageSent"
#define kNotificationMessageMarkRead        @"kNotificationMessageMarkRead"


#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define VERSION_GREATER_7  (IOS_VERSION > 6.99)

typedef void (^ResponseError)(Error* error);
typedef void (^ResponseBlock)();
typedef void (^ResponseArray)(NSArray *responseArray);
typedef void (^ResponseObject)(id object);
