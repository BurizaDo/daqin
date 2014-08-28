//
//  WeiboProvider.m
//  daqin
//
//  Created by BurizaDo on 8/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "WeiboProvider.h"
#import "EGOCache.h"
#import "WeiboSDK.h"

@interface WeiboProvider() <WBHttpRequestDelegate>

@end

@implementation WeiboProvider

static WeiboProvider *_sharedInstance = nil;

+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
    
}

- (void)getUserSuccess:(ResponseObject)obj failure:(ResponseError)err{
    NSString* url = @"https://api.weibo.com/2/users/show.json";
    NSDictionary* param = @{@"source":@"653706130",
                            @"access_Token":[[EGOCache globalCache] objectForKey:@"wb_access_token"],
                            @"uid":[[EGOCache globalCache] objectForKey:@"wb_uid"]};
    WBHttpRequest* request = [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:param delegate:self withTag:nil];
//    [WeiboSDK sendRequest:request];
//        NSData *data = [object dataUsingEncoding:NSUTF8StringEncoding];
//        if (data) {
//            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            dic = nil;
//        }

}

- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response{
    
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data{
    
}

@end
