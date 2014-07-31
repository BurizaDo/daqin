//
//  LoginUtil.h
//  daqin
//
//  Created by BurizaDo on 7/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginHelper : NSObject
+ (instancetype)sharedInstance;
- (void)doLogin;
@end
