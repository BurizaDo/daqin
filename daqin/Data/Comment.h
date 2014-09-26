//
//  Comment.h
//  daqin
//
//  Created by BurizaDo on 9/23/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Comment : NSObject

@property (nonatomic, strong) NSString* messageId;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) User* replyUser;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, assign) long long timestamp;

+ (instancetype)parseFromDictionary:(NSDictionary*)dic;
@end
