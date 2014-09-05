//
//  WeiboHelper.m
//  daqin
//
//  Created by BurizaDo on 8/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "WeiboHelper.h"
#import "EGOCache.h"
@interface WeiboHelper () <WBHttpRequestDelegate>
@end

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

- (void)getUserInfo{
    NSString* url = @"https://api.weibo.com/2/users/show.json";
    NSDictionary* param = @{@"source":@"653706130",
                            @"access_Token":[[EGOCache globalCache] objectForKey:@"wb_access_token"],
                            @"uid":[[EGOCache globalCache] objectForKey:@"wb_uid"]};
    [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:param delegate:self withTag:nil];
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

#pragma mark - WBHttpRequestDelegate
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response{
    
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{

}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data{
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if(![dic objectForKey:@"error_code"]){
        User* user = [[User alloc] init];
        user.userId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
        user.name = [dic objectForKey:@"name"];
        user.avatar = [dic objectForKey:@"avatar_large"];
        user.gender = [[dic objectForKey:@"gender"] isEqualToString:@"m"] ? @"男" : @"女";
        [_delegate handleUserResponse:user];

    }
}

@end
