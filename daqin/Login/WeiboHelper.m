//
//  WeiboHelper.m
//  daqin
//
//  Created by BurizaDo on 8/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "WeiboHelper.h"
#import "EGOCache.h"

@implementation WeiboHelper
static WeiboHelper *_sharedInstance = nil;

+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)doLogin{
    WBAuthorizeRequest* request = [WBAuthorizeRequest request];
    request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}


#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if(response.statusCode == WeiboSDKResponseStatusCodeSuccess && [response isKindOfClass:[WBAuthorizeResponse class]]){
        NSString* pre = @"uidwb_";
        NSString* wbuid = [pre stringByAppendingString:((WBAuthorizeResponse*)response).userID];
        [[EGOCache globalCache] setObject:wbuid forKey:@"userToken"];
        [[EGOCache globalCache] setObject:((WBAuthorizeResponse*)response).accessToken forKey:@"wb_access_token"];
        [[EGOCache globalCache] setObject:((WBAuthorizeResponse*)response).userID forKey:@"wb_uid"];
        [_delegate handleLoginResponse:wbuid type:LOGINTYPE_WEIBO];
    }
}

@end
