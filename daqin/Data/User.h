//
//  User.h
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* age;
@property (nonatomic, copy) NSString* signature;
@property (nonatomic, copy) NSString* avatar;
@property (nonatomic, copy) NSString* images;
@property (nonatomic, copy) NSString* gender;

+(instancetype) parseFromDictionary:(NSDictionary*) dic;
@end
