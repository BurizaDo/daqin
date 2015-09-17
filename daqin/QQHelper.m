//
//  LoginUtil.m
//  daqin
//
//  Created by BurizaDo on 7/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "QQHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "EGOCache.h"
#import "User.h"
#import "GlobalDataManager.h"

@interface QQHelper() //<TencentSessionDelegate>
@property (nonatomic, strong)TencentOAuth* tencentOAuth;

@end

@implementation QQHelper
//+ (instancetype)sharedInstance{
//    static id instance;
//	
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		instance = [[[self class] alloc] init];
//	});
//	
//	return instance;
//}
//
//- (id)init{
//    self = [super init];
//    if(self){
//        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1102004942" andDelegate:self];
//    }
//    return self;
//}
//
//- (void)doLogin{
//    
//    NSArray* permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
//    [_tencentOAuth authorize:permissions inSafari:YES];
//}
//
//- (void)getUserInfo{
//    [_tencentOAuth getUserInfo];
//}
//
//- (void)tencentDidLogin
//{
//    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]){
//        if(_delegate){
//            [_delegate handleLoginResponse:_tencentOAuth.openId type:LOGINTYPE_QQ];
//        }
//    }else{
//        
//    }
//}
//
//- (void)tencentDidNotLogin:(BOOL)cancelled{
//    
//}
//
//- (void)tencentDidNotNetWork{
//    
//}
//
//#pragma mark - TencentSessionDelegate
//
//- (void)tencentDidLogout{
//    
//}
//
//- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions{
//    return YES;
//}
//
//- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth{
//    return YES;
//}
//
//- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth{
//    
//}
//
//- (void)tencentFailedUpdate:(UpdateFailType)reason{
//    
//}
//
//- (void)getUserInfoResponse:(APIResponse*) response{
//    NSLog(@"getUserInfoResponse");
//    NSDictionary* data = response.jsonResponse;
//    User* user = [[User alloc] init];
//    user.userId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
//    user.name = [data objectForKey:@"nickname"];
//    user.avatar = [data objectForKey:@"figureurl_qq_2"];
//    [_delegate handleUserResponse:user];
//}
//
//- (void)getListAlbumResponse:(APIResponse*) response{
//    
//}
//
//- (void)getListPhotoResponse:(APIResponse*) response{
//    
//}
//
//- (void)checkPageFansResponse:(APIResponse*) response{
//    
//}
//
//- (void)addShareResponse:(APIResponse*) response{
//    
//}
//
//- (void)addAlbumResponse:(APIResponse*) response{
//    
//}
//
//- (void)uploadPicResponse:(APIResponse*) response{
//    
//}
//
//- (void)addTopicResponse:(APIResponse*) response{
//    
//}
//
//- (void)getVipInfoResponse:(APIResponse*) response{
//    
//}
//
//- (void)getVipRichInfoResponse:(APIResponse*) response{
//    
//}
//
//- (void)matchNickTipsResponse:(APIResponse*) response{
//    
//}
//
//- (void)getIntimateFriendsResponse:(APIResponse*) response{
//    
//}
//
//- (void)setUserHeadpicResponse:(APIResponse*) response{
//    
//}
//
//- (void)sendStoryResponse:(APIResponse*) response{
//    
//}
//
//- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message{
//    
//}
//
//- (void)tencentOAuth:(TencentOAuth *)tencentOAuth didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite userData:(id)userData{
//    
//}
//
//- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController{
//    
//}


@end
