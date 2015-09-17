//
//  Route.h
//  daqin
//
//  Created by BurizaDo on 7/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@interface Club : NSObject
@property int clubId;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSArray* images;
@property double longitude;
@property double latitude;
@property (nonatomic, copy) NSString* address;
@property (nonatomic, assign) NSDictionary* meta;
@end
