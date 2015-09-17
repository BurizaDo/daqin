//
//  Route.h
//  daqin
//
//  Created by BurizaDo on 9/17/15.
//  Copyright (c) 2015 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Route : NSObject
@property (nonatomic, strong) User* user;
@property (nonatomic, copy) NSString* routeId;
@property (nonatomic, copy) NSString* startTime;
@property (nonatomic, copy) NSString* endTime;
@property (nonatomic, copy) NSString* description;
@property (nonatomic, copy) NSString* destination;

@end
