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
    if(user.images.length == 0){
        user.images = nil;
    }
    user.gender = [dic objectForKey:@"gender"];
    return user;
}

- (id) init{
    self = [super init];
    if(self){
        _gender = _userId = _name = _age = _signature = _avatar = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_userId forKey:@"userId"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_age forKey:@"age"];
    [aCoder encodeObject:_signature forKey:@"signature"];
    [aCoder encodeObject:_avatar forKey:@"avatar"];
    [aCoder encodeObject:_images forKey:@"images"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    User* user = [[User alloc] init];
    user.userId = [aDecoder decodeObjectForKey:@"userId"];
    user.name = [aDecoder decodeObjectForKey:@"name"];
    user.age = [aDecoder decodeObjectForKey:@"age"];
    user.signature = [aDecoder decodeObjectForKey:@"signature"];
    user.avatar = [aDecoder decodeObjectForKey:@"avatar"];
    user.images = [aDecoder decodeObjectForKey:@"images"];
    return user;
}

@end
