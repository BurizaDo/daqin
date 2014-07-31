//
//  User.m
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "User.h"

@implementation User
+(instancetype) parseFromDictionary:(NSDictionary*) dic{
    User* user = [[User alloc] init];
    user.userId = [dic objectForKey:@"userId"];
    user.name = [dic objectForKey:@"name"];
    user.age = [dic objectForKey:@"age"];
    user.signature = [dic objectForKey:@"signature"];
    user.avatar = [dic objectForKey:@"avatar"];
    user.images = [dic objectForKey:@"images"];
    return user;
}
@end
