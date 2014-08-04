//
//  UserProvider.m
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "UserProvider.h"
#import "HttpClient.h"
#import "user.h"

@implementation UserProvider
+ (void)getUsers:(NSString*)userIds
       onSuccess:(void(^)(NSArray *areas))resultBlock
       onFailure:(void(^)(NSString* error))failureBlock{
    NSDictionary* param = @{@"userIds":userIds};
    [[HttpClient sharedClient] getAPI:@"getUser" params:param success:^(id obj) {
        NSArray* ary = obj;
        NSMutableArray* users = [[NSMutableArray alloc] init];
        for(NSDictionary* dic in ary){
            [users addObject:[User parseFromDictionary:dic]];
        }
        resultBlock(users);
    } failure:^(NSString *errMsg) {
        if(failureBlock){
            failureBlock(errMsg);
        }
    }];
}

+ (void)updateUser:(User*)user
         onSuccess:(void(^)())resultBlock
         onFailure:(void(^)())failureBlock{
    NSDictionary* param = @{@"userId":user.userId,
                            @"name":user.name,
                            @"age":user.age,
                            @"signature":user.signature,
                            @"avatar":user.avatar,
                            @"images":user.images};
    [[HttpClient sharedClient] getAPI:@"updateUserProfile" params:param success:^(id obj) {
        resultBlock();
    } failure:^(NSString *errMsg) {
        if(failureBlock){
            failureBlock(errMsg);
        }
    }];
    
}

@end
