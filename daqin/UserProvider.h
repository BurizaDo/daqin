//
//  UserProvider.h
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProvider : NSObject
+ (void)getUsers:(NSString*)userIds
                onSuccess:(void(^)(NSArray *areas))resultBlock
                onFailure:(void(^)(NSString* error))failureBlock;

@end
