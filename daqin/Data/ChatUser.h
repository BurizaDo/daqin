//
//  BXChatUser.h
//  Data
//
//  Created by minjie on 14-5-28.
//  Copyright (c) 2014年 Baixing. All rights reserved.
//

@interface ChatUser : NSObject

@property (nonatomic,copy) NSString* peerId;
@property (nonatomic,copy) NSString* displayName;
@property (nonatomic,copy) NSString* iconUrl;

- (id) initWithPeerId:(NSString*)peerId displayName:(NSString*)displayName iconUrl:(NSString*)iconUrl;

@end
