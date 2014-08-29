//
//  LoginManager.h
//  daqin
//
//  Created by BurizaDo on 8/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginManager : NSObject
+ (instancetype) sharedInstance;

- (void)loginQQ;

- (void)loginWeibo;

- (BOOL)handleOpenURL:(NSURL*)url;
@end
