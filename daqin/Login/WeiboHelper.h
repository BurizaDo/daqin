//
//  WeiboHelper.h
//  daqin
//
//  Created by BurizaDo on 8/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "LoginDelegate.h"

@interface WeiboHelper : NSObject <WeiboSDKDelegate>
@property (nonatomic, assign) id<LoginDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)doLogin;

- (void)getUserInfo;
@end
