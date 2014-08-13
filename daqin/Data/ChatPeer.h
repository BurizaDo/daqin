//
//  HJChatPeer.h
//  Baixing
//
//  Created by neoman on 5/22/14.
//
//


@interface ChatPeer : NSObject

@property (nonatomic, assign) BOOL              enableChat;
@property (nonatomic, assign) NSTimeInterval    expire;
@property (nonatomic, copy) NSString            *receiverId;
@property (nonatomic, strong) NSArray           *supportFormat;
@property (nonatomic, copy) NSString            *userId;
@property (nonatomic, copy) NSString            *anonymousId;
@property (nonatomic, strong) NSDictionary      *settings;
@property (nonatomic, copy) NSString            *statusText;

@end
