//
//  UserProvider.h
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "EventDefinition.h"

@interface UserProvider : NSObject
+ (void)getUsers:(NSString*)userIds
                onSuccess:(ResponseArray)resultBlock
                onFailure:(ResponseError)failureBlock;

+ (void)updateUser:(User*)user
         onSuccess:(void(^)())resultBlock
         onFailure:(ResponseError)failureBlock;

+ (void)registerUser:(NSString*)account
            password:(NSString*)pwd
           onSuccess:(ResponseObject)successBlock
           onFailure:(ResponseError)failureBlock;

+ (void)login:(NSString*)account
            password:(NSString*)pwd
           onSuccess:(ResponseObject)successBlock
           onFailure:(ResponseError)failureBlock;

@end
