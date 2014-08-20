//
//  ChatSession.m
//  daqin
//
//  Created by BurizaDo on 8/11/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ChatSession.h"
#import "AVOSCloud/AVOSCloud.h"
#import "AVOSCloud/AVInstallation.h"
#import "ChatUser.h"
#import "EventDefinition.h"
#import "MessageProvider.h"
#import "EGOCache.h"
#import <CommonCrypto/CommonHMAC.h>
#import "UserProvider.h"

#define APPID @"72atif126iweafj2eu4v78ip7sa6u72wfx3u4vx1mobsyngs"
#define CLIENTKEY @"z9kai6hs3qit5ri8arkciiqh8q0z8gilmpzzb0baczp1hx81"
#define MASTERKEY @"ozda1dxhbj63aist40jk20md1ukzwnxgw14qzccqvzpgpenf"

@interface ChatSession() <AVSessionDelegate, AVSignatureDelegate>

@property (nonatomic, strong) AVSession *avSession;

@property (nonatomic, strong) NSMutableDictionary *signatures;

@end


@implementation ChatSession
static ChatSession *_sharedInstance = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (void) setup{
    [AVOSCloud setApplicationId:APPID clientKey:CLIENTKEY];
    _avSession = [[AVSession alloc] init];
    _avSession.sessionDelegate = self;
    _avSession.signatureDelegate = self;

}

- (void) enableChat:(ChatUser*)selfUser{
    self.selfUser = selfUser;
    [_avSession open:selfUser.peerId withPeerIds:@[]];
}

- (void) setDeviceToken:(NSData*)token{
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:token];
    
    [currentInstallation saveInBackground];
}

+ (void)sendMessage:(NSString*)content
{
    ChatSession *chatSession = [self sharedInstance];
    
    if ([chatSession.avSession isOpen] && [chatSession.avSession isPaused]) {
        
        [chatSession.avSession close];
        [chatSession.avSession open:chatSession.selfUser.peerId withPeerIds:@[chatSession.receiverUser.peerId]];
    }
    NSString* receiveId = chatSession.receiverUser.peerId;
    [chatSession.avSession watchPeers:@[receiveId]];
    [chatSession.avSession sendMessage:content isTransient:NO toPeerIds:@[receiveId]];
}


#pragma mark - avsessiionDelegate methods

- (void)onSessionOpen:(AVSession *)session
{

}

- (void)onSessionPaused:(AVSession *)session
{

}

- (void)onSessionResumed:(AVSession *)seesion
{

}

- (void)onSessionMessage:(AVSession *)session message:(NSString *)message peerId:(NSString *)peerId
{
    //把消息添加到本地数据库
    ChatSession* chatSession = [ChatSession sharedInstance];
    NSString* myPeerId = chatSession.selfUser.peerId;
    BOOL isChatting = [peerId isEqualToString:self.isChattingPeerId];
    [MessageProvider addMessageWithContent:message fromId:peerId toId:myPeerId isRead:isChatting];
    
    [UserProvider getUsers:peerId onSuccess:^(NSArray *responseArray) {
        User* user = responseArray[0];
        ChatUser* cu = [[ChatUser alloc] initWithPeerId:peerId displayName:user.name iconUrl:user.avatar];
        [MessageProvider saveChatUser:cu];
    } onFailure:^(Error *error) {
        
    }];
    
    
    if (isChatting) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewMessage object:peerId];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadSessionFromDB object:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifcationMessageChange object:nil];
}

- (void)onSessionStatusOnline:(AVSession *)session peers:(NSArray *)peerIds
{

}

- (void)onSessionStatusOffline:(AVSession *)session peers:(NSArray *)peerId
{

}

- (void)onSessionError:(AVSession *)session withException:(NSException *)exception
{

}

- (void)onSessionMessageSent:(AVSession *)session message:(NSString *)message toPeerIds:(NSArray *)peerIds
{

    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString* guid = dic[@"guid"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageSent object:guid];
    }
}

- (void)onSessionMessageFailure:(AVSession *)session message:(NSString *)message toPeerIds:(NSArray *)peerIds
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString* guid = dic[@"guid"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageSentFail object:guid];
    }
}

#pragma mark - AVSignatureDelegate
- (AVSignature *)createSignature:(NSString *)peerId watchedPeerIds:(NSArray *)watchedPeerIds {
    NSString *appId = APPID;
    
    AVSignature *signature = [[AVSignature alloc] init];
    signature.timestamp = [[NSDate date] timeIntervalSince1970];
    signature.nonce = @"ForeverAlone";
    
    NSArray *sortedArray = [watchedPeerIds sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    signature.signedPeerIds = sortedArray;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObject:appId];
    [tempArray addObject:peerId];
    
    if ([sortedArray count]> 0) {
        [tempArray addObjectsFromArray:sortedArray];
    } else {
        [tempArray addObject:@""];
    }
    
    [tempArray addObject:@(signature.timestamp)];
    [tempArray addObject:signature.nonce];
    
    NSString *message = [tempArray componentsJoinedByString:@":"];
    NSString *secret = MASTERKEY;
    signature.signature = [self hmacsha1:message key:secret];
    
    return signature;
}

- (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    return [self hexStringWithData:result ofLength:CC_SHA1_DIGEST_LENGTH];
}

- (NSString*) hexStringWithData:(unsigned char*) data ofLength:(NSUInteger)len {
    NSMutableString *tmp = [NSMutableString string];
    for (NSUInteger i=0; i<len; i++)
        [tmp appendFormat:@"%02x", data[i]];
    return [NSString stringWithString:tmp];
}


@end
