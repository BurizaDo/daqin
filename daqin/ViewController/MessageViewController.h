//
//  BXMessageViewController.h
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//


@class ChatUser;

@interface MessageViewController : UIViewController

@property (nonatomic,strong) NSMutableArray* messages;

/**
 *  从联系人进入会给peerId赋值
 */
@property (nonatomic, strong) ChatUser            *receiverChatUser;

@property (nonatomic, assign) BOOL                  isPresented;


- (void)initData;

- (void)handleDoubleHitGesture:(id)sender;

@end
