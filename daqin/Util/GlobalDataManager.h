//
//  GlobalDataManager.h
//  daqin
//
//  Created by BurizaDo on 8/11/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
@interface GlobalDataManager : NSObject
@property (nonatomic, strong) User* user;

+ (instancetype) sharedInstance;
@end
