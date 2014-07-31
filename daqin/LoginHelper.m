//
//  LoginUtil.m
//  daqin
//
//  Created by BurizaDo on 7/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "LoginHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface LoginHelper() <TencentSessionDelegate>
@property (nonatomic, strong)TencentOAuth* tencentOAuth;

@end

@implementation LoginHelper
+ (instancetype)sharedInstance{
    static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (id)init{
    self = [super init];
    if(self){
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"100390799" andDelegate:self];
    }
    return self;
}

- (void)doLogin{
    NSArray* permissions = [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo", @"add_t", nil];
    [_tencentOAuth authorize:permissions inSafari:NO];
}

- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]){
//        _labelAccessToken.text = _tencentOAuth.accessToken;
    }else{
//        _labelAccessToken.text = @"登录不成功 没有获取accesstoken";
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    
}

- (void)tencentDidNotNetWork{
    
}

@end
