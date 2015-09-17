//
//  LoginManager.m
//  daqin
//
//  Created by BurizaDo on 8/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "LoginManager.h"
#import "QQHelper.h"
#import "WeiboHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "LoginDelegate.h"
#import "EGOCache.h"
#import "UserProvider.h"
#import "GlobalDataManager.h"
#import "ChatUser.h"
#import "ChatSession.h"

@interface LoginManager() <LoginDelegate>

@end

@implementation LoginManager
static LoginManager *_sharedInstance = nil;

+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)loginQQ{
//    [QQHelper sharedInstance].delegate = self;
//    [[QQHelper sharedInstance] doLogin];
}

- (void)loginWeibo{
    [WeiboHelper sharedInstance].delegate = self;
    [[WeiboHelper sharedInstance] doLogin];
}



- (BOOL)handleOpenURL:(NSURL*)url{
    NSString* str = [url absoluteString];
    if([str rangeOfString:@"tencent"].location != NSNotFound){
//        return [TencentOAuth HandleOpenURL:url];
        return NO;
    }else{
        return [WeiboSDK handleOpenURL:url delegate:[WeiboHelper sharedInstance]];
    }

}

-(void)getUserInfo:(NSString*)userId{
    [UserProvider getUsers:userId onSuccess:^(NSArray *users) {
        if([users count] == 0) return;
        User* user = users[0];
        [GlobalDataManager sharedInstance].user = user;
        
        ChatUser* selfUser = [[ChatUser alloc] initWithPeerId:user.userId displayName:user.name iconUrl:user.avatar];
        [[ChatSession sharedInstance] enableChat:selfUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil];
    } onFailure:^(Error *error) {
        if(error.errorCode){
            if([userId rangeOfString:@"uidqq"].location != NSNotFound){
//                [[QQHelper sharedInstance] getUserInfo];
            }else{
                [[WeiboHelper sharedInstance] getUserInfo];
            }
        }
    }];
}

#pragma mark - LoginDelegate
-(void)handleLoginResponse:(NSString*)response type:(LoginType)type{
    if(type == LOGINTYPE_QQ){
        NSString* pre = @"uidqq_";
        NSString* qquid = [pre stringByAppendingString:response];
        [[EGOCache globalCache] setObject:qquid forKey:@"userToken"];
        [self getUserInfo:qquid];
    }else{
        [self getUserInfo:response];
    }
}

-(void)handleUserResponse:(User*)user{
    [GlobalDataManager sharedInstance].user = user;
    [UserProvider updateUser:user onSuccess:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil];
    } onFailure:^(Error *error) {
        
    }];
}


@end
