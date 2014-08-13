//
//  HJMessageProvider.h
//  Provider
//
//  Created by minjie on 14-5-13.
//  Copyright (c) 2014年 Baixing. All rights reserved.
//

#import "EventDefinition.h"

@class Message, MessageInfo, ChatPeer, ChatUser;


@interface MessageProvider : NSObject

/**
 *  获得两个人之间的全部消息
 *
 *  @param fromId 发送者的Id
 *  @param toId   接收者的Id
 *
 *  @return 对应的消息数组
 */
+ (NSArray*)getAllMessagesWithFromId:(NSString*)fromId toId:(NSString*)toId;

/**
 *  将fromId和toId之间的会话都置为已读
 *
 *  @param fromId fromId
 *  @param toId   toId
 *
 *  @return 是否更新成功
 */
+ (BOOL)markAllMessageReadWithFromId:(NSString *)fromId toId:(NSString *)toId;

/**
 *  新增Message
 *
 *  @param id           message的globalId
 *  @param fromId       发送者的Id
 *  @param toId         接受者Id
 *  @param status       消息发送状态
 *  @param timestamp    消息发送时间
 *  @param type         消息的类型（文字、图片、地址、ad）
 *  @param type         消息的内容（文字、图片、地址、ad）
 *  @param read         消息已读未读
 *  @param object       消息序列化对象
 *
 *  @return 是否插入成功
 */
+ (BOOL)addMessageWithId:(NSString *) mId
                  fromId:(NSString *) fromId
                    toId:(NSString *) toId
                  status:(int) status
               timestamp:(NSTimeInterval) timestamp
                    type:(NSString *) type
                 content:(NSString *) content
                    read:(int) read
                  object:(NSData *) object;

/**
 *  插入一条消息
 *
 *  @param message 消息
 *
 *  @return 是否插入成功
 */
+ (BOOL)addMessage:(Message*)message;

/**
 *  收到消息，插入数据库
 *
 *  @param content json格式
 *  @param fromId  发消息人的peerId
 *
 *  @return add msg 到本地数据库是否成功
 */
+ (BOOL)addMessageWithContent:(NSString*)content
                       fromId:(NSString*)fromId
                         toId:(NSString*)toId
                       isRead:(BOOL)isRead;


/**
 *  自己由匿名用户切为登录用户时, 需将更新chat_message
 *
 *  @param oldId        匿名id
 *  @param newId 登录Id
 *
 *  @return 是否转换成功
 */
+ (BOOL)exchangeMyPeerId:(NSString *)oldId newMyPeerId:(NSString *)newId;

/**
 *  保存用户的peerInfo
 *
 *  @param chatPeer 用户的peerInfo
 *
 *  @return 是否保存成功
 */
+ (BOOL)saveChatUser:(ChatUser *)chatUser;

/**
 *  删除一个联系人
 *
 *  @param receiverId receiverId
 *
 *  @return 是否删除成功
 */
+ (BOOL)removeChatPeerWithReceiverId:(NSString *)receiverId;

/**
 *  获取首页私信item所需的信息
 *
 *  @return 返回一个BXMessageInfo实例
 */
+ (MessageInfo *)queryMessageInfoSummaryUserChatId:(NSString *)userChatId;

/**
 *  查询联系人列表, 同时包含每个联系人最近的联系内容和联系
 *
 *  @return
 */
+ (NSArray *)queryMessageInfoList;

/**
 *  根据receiverId查找联系人
 *
 *  @param receiverId receiverId
 *
 *  @return BXChatUser
 */
+ (ChatUser*)queryChatUserWithReceiverId:(NSString*)receiverId;

/**
 *  更新消息数据表离的object字段，如接受到的ad，ad内容下载下来以后换存在本地
 *
 *  @param message message
 */
+ (void)updateMessageObject:(Message*)message;

/**
 *  清空所有的信息
 *
 *  @return 是否清楚成功
 */
+ (BOOL)deleteAll;

+ (void) addToBlackList:(NSString*)userToken
                 selfId:(NSString*)selfId
                blackIds:(NSArray*)blackIds
           installation:(NSString*)installId
              onSuccess:(ResponseBlock)success
              onFailure:(ResponseError)fail;

+ (void) removeFromBlackList:(NSString*)userToken
                 selfId:(NSString*)selfId
               blackIds:(NSArray*)blackIds
           installation:(NSString*)installId
              onSuccess:(ResponseBlock)success
              onFailure:(ResponseError)fail;

+ (void) getBlackList:(NSString*)userToken
               selfId:(NSString*)selfId
         installation:(NSString*)installId
            onSuccess:(ResponseArray)success
            onFailure:(ResponseError)fail;

@end
