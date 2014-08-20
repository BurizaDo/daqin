//
//  HJMessageProvider.m
//  Provider
//
//  Created by minjie on 14-5-13.
//  Copyright (c) 2014年 Baixing. All rights reserved.
//

#import "MessageProvider.h"
#import <FMDatabaseQueue.h>
#import <FMDatabase.h>
#import "Message.h"
#import "MessageInfo.h"
#import "NSString+JSON.h"
#import "NSDate+TimeAgo.h"
#import "NSDictionary+JSON.h"
#import "NSString+JSON.h"
#import "ChatUser.h"
#import "NSString+BCAdditions.h"
#import "HttpClient.h"
#import "ChatPeer.h"
#import "Store.h"

#define DB_FILE_NAME                @"message.db"

#define DBMessageTypeImage          @"image"
#define DBMessageTypeText           @"text"
#define DBMessageTypeAd             @"ad"
#define DBMessageTypeLocation       @"location"
#define DBMessageTypeVoice          @"voice"

@implementation MessageProvider

+ (void)initialize
{
    if (self != [MessageProvider class]) {
        return;
    }
        
    // create the db & table
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self dbFilePath]] == NO) {
        FMDatabase *db = [FMDatabase databaseWithPath:[self dbFilePath]];
        if ([db open]) {
            //消息表
            NSString *sql = @"CREATE TABLE chat_message(\
                id INTEGER primary key AUTOINCREMENT,\
                guid varchar UNIQUE,\
                type varchar not null,\
                fromId varchar,\
                toId varchar,\
                timestamp long,\
                content varchar,\
                status int, \
                read int, \
                object BLOB);";
            [db executeUpdate:sql];
            
            //聊天表
            sql = @"CREATE TABLE chat_friends( \
                fid INTEGER primary key AUTOINCREMENT, \
                receiverId varchar UNIQUE not null, \
                type varchar, \
                lastChatTime long, \
                avatar varchar,\
                displayName varchar,\
                settings varchar);";
            [db executeUpdate:sql];
            
            [db close];
        }
    }
}

+ (NSArray*)getAllMessagesWithFromId:(NSString *)fromId toId:(NSString *)toId
{
    NSMutableArray* items = [NSMutableArray array];
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString * sql = @"SELECT * FROM chat_message where fromId = ? AND toId = ? OR fromId = ? AND toId = ? ORDER BY id";
        FMResultSet * rs = [db executeQuery:sql,fromId,toId,toId,fromId];
        
        while ([rs next]) {
            NSString* type = [rs stringForColumn:@"type"];
            Message* message = [Message createMessageWithType:type];
            message.guid = [rs stringForColumn:@"guid"];
            message.fromId = [rs stringForColumn:@"fromId"];
            if ([message.fromId isEqualToString:fromId]) {
                message.from = MessageFromMine;
            }
            else{
                message.from = MessageFromOther;
            }
            message.toId = [rs stringForColumn:@"toId"];
            message.state = [rs intForColumn:@"status"];
            long timestamp = [rs longForColumn:@"timestamp"];
            message.time = [NSDate dateWithTimeIntervalSince1970:timestamp];
            message.content = [rs stringForColumn:@"content"];
            message.read = [rs intForColumn:@"read"];
            message.object = [rs dataForColumn:@"object"];
            [message loadObject];
            
            [items addObject:message];
        }
        
        [rs close];
    }];
    
    return items;
}

+ (BOOL)markAllMessageReadWithFromId:(NSString *)fromId toId:(NSString *)toId
{
    __block BOOL result = NO;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE chat_message SET read = 1 \
            WHERE ((fromId = ? AND toId = ?) OR (fromId = ? AND toId = ?)) AND read = 0";
        result = [db executeUpdate:sql, fromId, toId, toId, fromId];
    }];
    
    return result;
}

+ (BOOL)addMessage:(Message*)message
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];

    BOOL ret = [MessageProvider addMessageWithId: message.guid
                                            fromId: message.fromId
                                              toId: message.toId
                                            status: message.state
                                         timestamp: timestamp
                                              type: [message typeString]
                                           content: [message content]
                                              read: message.read
                                            object: [message objectData]];
    
    return ret;
}

+ (BOOL)saveChatUser:(ChatUser *)chatUser
{
    BOOL isChatFriendExist = [self isChatExistWithReceivedId:chatUser.peerId];
    
    if (isChatFriendExist) {
        return [self updateChatFriend:chatUser];
    } else {
        return [self insertChatFriend:chatUser];
    }
}

+ (BOOL)removeChatPeerWithReceiverId:(NSString *)receiverId
{
    __block BOOL result;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"delete from chat_friends WHERE receiverId = ?";
        result = [db executeUpdate:sql, receiverId];
    }];
    
    return result;
}

+ (MessageInfo *)queryMessageInfoSummaryUserChatId:(NSString *)userChatId
{
    MessageInfo *messageInfo = [MessageInfo new];
    
    if ([userChatId length] == 0) {
        return nil;
    }
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"SELECT f.receiverId, f.type, f.lastChatTime, f.settings,\
            sum(case when m.read = 0 and m.fromId = f.receiverId then 1 else 0 end) as count, \
            m.id, m.guid, m.type, m.fromId, m.toId, m.timestamp, m.content, m.status, m.read, m.object, max(m.id)\
            from chat_friends f left join chat_message m on (m.fromId = f.receiverId and m.toId = ?)\
            OR (m.fromId = ? and m.toId = f.receiverId)\
            where 1 = 1 \
            order by m.id DESC";
        FMResultSet *rs = [db executeQuery:sql, userChatId, userChatId];
        while ([rs next]) {
            messageInfo.badgeCount = [rs intForColumn:@"count"];
            NSString *contentData = [rs stringForColumn:@"content"];
            NSString *type = [rs stringForColumn:@"type"];
            messageInfo.content = [self extractContentFromContentData:contentData type:type];
            messageInfo.timeStamp = [rs dateForColumn:@"timestamp"];
        }
        [rs close];
    }];
    
    return messageInfo;
}

+ (NSArray *)queryMessageInfoList
{
    NSMutableArray *result = [NSMutableArray array];
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inDatabase:^(FMDatabase *db) {
       
        NSString *sql = @"SELECT f.receiverId, f.avatar, f.displayName, sum(case when m.read = 0 and m.fromId = f.receiverId then 1 else 0 end) as readCount,\
                            m.content, m.type, m.timestamp, m.id \
                            FROM chat_friends f \
                            LEFT JOIN chat_message m \
                            ON f.receiverId = m.fromId OR f.receiverId = m.toId \
                            GROUP by f.receiverId \
                            ORDER BY m.id DESC";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MessageInfo *messageInfo = [MessageInfo new];
            messageInfo.badgeCount = [rs intForColumn:@"readCount"];
            NSString *contentData = [rs stringForColumn:@"content"];
            NSString *type = [rs stringForColumn:@"type"];
            messageInfo.content = [self extractContentFromContentData:contentData type:type];
//            NSDictionary *settings = [[rs stringForColumn:@"settings"] objectFromJSONString];
//            messageInfo.name = settings[@"displayName"];
//            messageInfo.iconUrl = settings[@"icon"];
            messageInfo.name = [rs stringForColumn:@"displayName"];
            messageInfo.iconUrl = [rs stringForColumn:@"avatar"];
            messageInfo.timeStamp = [rs dateForColumn:@"timestamp"];
            messageInfo.receiveId = [rs stringForColumn:@"receiverId"];
            [result addObject: messageInfo];
        }
        
        [rs close];
    }];
    
    return result;
}

+ (ChatUser*)queryChatUserWithReceiverId:(NSString*)receiverId
{
    __block ChatUser *chatUser;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"SELECT avatar,displayName from chat_friends where receiverId = ?";
        FMResultSet *rs = [db executeQuery:sql,receiverId];
        if ([rs next]) {
            chatUser = [ChatUser new];
            chatUser.peerId = receiverId;
//            NSDictionary *settings = [[rs stringForColumn:@"settings"] objectFromJSONString];
            chatUser.displayName = [rs stringForColumn:@"displayName"];
            chatUser.iconUrl = [rs stringForColumn:@"avatar"];
        }
        
        [rs close];
    }];
    
    return chatUser;
}

+ (void)updateMessageObject:(Message*)message
{
    NSData* data = [message objectData];
    NSTimeInterval timestamp = [message.time timeIntervalSince1970];
    
    FMDatabaseQueue *queue = [self fmDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"UPDATE chat_message SET timestamp = ?, status = ?, object = ? WHERE guid = ?",@(timestamp), @(message.state), data, message.guid];
    }];
}

+ (BOOL) addMessageWithContent:(NSString*)content
                        fromId:(NSString*)fromId
                          toId:(NSString*)toId
                        isRead:(BOOL)read
{
    NSDictionary *dic = [content objectFromJSONString];
    
    NSDictionary *contentDic = dic[@"content"];
    if (contentDic == nil) {
        return NO;
    }

    NSString* type = dic[@"type"];
    NSString* guid = dic[@"guid"];
    
    Message *message = nil;
    
    if ([type isEqualToString:DBMessageTypeText]) {
        message = [Message createTextMessage:contentDic[@"text"] from:MessageFromOther];
        
    } else if([type isEqualToString:DBMessageTypeImage]) {
        
        CGSize imageSize = CGSizeZero;
        CGFloat height = [contentDic[@"height"] floatValue];
        CGFloat width = [contentDic[@"width"] floatValue];
        if (height > 0 && width > 0) {
            imageSize = CGSizeMake(width, height);
        }
        
        message = [Message createImageMessageWithImage:nil
                                               imageSize:imageSize
                                                imageUrl:contentDic[@"url"]
                                                    from:MessageFromOther];
    } else if([type isEqualToString:DBMessageTypeVoice]){
        message = [Message createVoiceMessage:contentDic[@"url"]
                                      localPath:nil
                                       duration:[contentDic[@"duration"] intValue]
                                           from:MessageFromOther];
    }
    else{
        message = [Message createTextMessage:@"正在使用的百姓网版本过低，无法展示对方的消息。请尽快升级" from:MessageFromOther];
    }
    
    message.fromId = fromId;
    message.toId = toId;
    message.guid = guid;
    message.read = read;
    message.state = MessageStateSendOK;
    
    BOOL result = NO;
    
    BOOL isChatFriendExist = [self isChatExistWithReceivedId:fromId];
    
    if (isChatFriendExist) {
        result = [self addMessage:message];
    } else {
        ChatPeer *chatPeer = [ChatPeer new];
        chatPeer.receiverId = fromId;
        chatPeer.enableChat = YES;
        result = [self addMessage:message chatPeer:chatPeer];
    }
    
    return result;
}

#pragma mark - chat_friend DAO methods

+ (BOOL)exchangeOldReceiverId:(NSString *)receiverId withNewPeer:(ChatPeer *)newChatPeer
{
    /**
     *  1 chat_friends删除老的记录, 添加新的记录
     *  2 chat_message更新fromId和toId;
     **/
    FMDatabaseQueue *queue = [self fmDatabaseQueue];
    __block BOOL result = NO;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        rollback = &result;
        
        [db executeUpdate:@"DELETE FROM chat_friends WHERE receiverId = ?", receiverId];
        [db executeUpdate:@"INSERT INTO chat_friends (receiverId, lastChatTime, settings) \
         VALUES (?, ?, ?)", newChatPeer.receiverId, [NSDate date], [newChatPeer.settings JSONString]];
        [db executeUpdate:@"UPDATE chat_message SET fromId = ? WHERE fromId = ?", newChatPeer.receiverId, receiverId];
        [db executeUpdate:@"UPDATE chat_message SET toId = ? WHERE toId = ?", newChatPeer.receiverId, receiverId];
    }];
    
    return result;
}

+ (BOOL)exchangeMyPeerId:(NSString *)oldId newMyPeerId:(NSString *)newId
{
    /**
     *  2 chat_message更新fromId和toId;
     **/
    FMDatabaseQueue *queue = [self fmDatabaseQueue];
    __block BOOL result = NO;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        rollback = &result;
    
        [db executeUpdate:@"UPDATE chat_message SET fromId = ? WHERE fromId = ?", newId, oldId];
        [db executeUpdate:@"UPDATE chat_message SET toId = ? WHERE toId = ?", newId, oldId];
    }];
    
    return result;
}

+ (BOOL)shouldAddMessageItem
{
    __block BOOL result = NO;
    
    FMDatabaseQueue *queue = [self fmDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM chat_message  WHERE type!='state' limit 1"];
        while ([rs next]) {
            NSString *mid = [rs stringForColumn:@"id"];
            result = [mid length] != 0;
        }
        
        [rs close];
    }];
    
    return result;
}

+ (BOOL)isChatExistWithReceivedId:(NSString*)receivedId
{
    __block BOOL result = NO;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString* sql = @"SELECT * FROM chat_friends WHERE receiverId = ?";
        FMResultSet * rs = [db executeQuery:sql,receivedId];
        if ([rs next]) {
            result = YES;
        }
        
        [rs close];
    }];
    
    return result;
}

+ (BOOL)insertChatFriend:(ChatUser *)chatPeer
{
    __block BOOL result;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"INSERT INTO chat_friends (receiverId, lastChatTime, avatar, displayName) \
                            VALUES (?, ?, ?, ?)";
        result = [db executeUpdate:sql,
                  chatPeer.peerId,
                  [NSDate date],
                  chatPeer.iconUrl,
                  chatPeer.displayName];
    }];
    
    return result;
}

+ (BOOL)updateChatFriend:(ChatUser *)chatPeer
{
    __block BOOL result;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE chat_friends SET lastChatTime = ?, avatar=?,displayName=? WHERE receiverId = ?";
        result = [db executeUpdate:sql, [NSDate date], chatPeer.iconUrl, chatPeer.displayName, chatPeer.peerId];
    }];
    
    return result;
}

+ (BOOL)deleteChatFriend:(NSString *)receiverId
{
    __block BOOL result;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"DELETE FROM chat_friends WHERE receiverId = ?";
        result = [db executeUpdate:sql, receiverId];
    }];
    
    return result;
}

#pragma mark - message DAO related method

+ (BOOL)deleteAll
{
    __block BOOL result = NO;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        rollback = &result;
        NSString *sql = @"DELETE FROM chat_message";
        [db executeUpdate:sql];
        sql = @"DELETE FROM chat_friends";
        [db executeUpdate:sql];
    }];
    
    return result;
}

+ (BOOL)addMessageWithId:(NSString*)guid
                  fromId:(NSString*)fromId
                    toId:(NSString*)toId
                  status:(int)status
               timestamp:(NSTimeInterval)timestamp
                    type:(NSString*)type
                 content:(NSString*)content
                    read:(int)read
                  object:(NSData*)object
{
    __block BOOL result = NO;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"INSERT INTO chat_message (guid, fromId, toId, status,\
        timestamp, type, content, read, object) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        result = [db executeUpdate:sql, guid, fromId, toId, @(status),
                  @(timestamp), type, content, @(read), object];
    }];
    
    return result;
}

+ (BOOL)addMessage:(Message *)message chatPeer:(ChatPeer *)chatPeer
{
    __block BOOL result = NO;
    
    FMDatabaseQueue *dbQueue = [self fmDatabaseQueue];
    
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        rollback = &result;
        
        NSString *sql = @"INSERT INTO chat_friends (receiverId, lastChatTime) \
        VALUES (?, ? )";
        [db executeUpdate:sql, chatPeer.receiverId, [NSDate date]];
        
        sql = @"INSERT INTO chat_message (guid, fromId, toId, status,\
                    timestamp, type, content, read, object) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        [db executeUpdate:sql, message.guid, message.fromId, message.toId, @(message.state),
         message.time, message.typeString, message.content, @(message.read), message.object];
    }];
    
    return result;
}

#pragma mark - private methods

+ (NSString *)dbFilePath
{
    NSString *docDirectoryPath = BXDocumentPath;
    NSString  *dbFileStr = [docDirectoryPath stringByAppendingPathComponent:DB_FILE_NAME];
    
#ifdef DEBUG
    NSLog(@"%@", dbFileStr);
#endif
    
    return dbFileStr;
}

+ (FMDatabaseQueue *)fmDatabaseQueue
{
    static FMDatabaseQueue *queue = nil;
    if (queue == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            queue = [FMDatabaseQueue databaseQueueWithPath:[self dbFilePath]];
        });
    }
    
    return queue;
}

+ (NSString *)extractContentFromContentData:(NSString *)contentData type:(NSString *)type
{
    NSString *content = nil;
    
    if ([type isEqualToString:DBMessageTypeText]) {
        
        NSDictionary *dic = [contentData objectFromJSONString];
        content = dic[@"text"];
        
    } else if ([type isEqualToString:DBMessageTypeImage]) {
        
        content = @"[图片]";
    } else if ([type isEqualToString:DBMessageTypeLocation]) {
        
        content = @"[位置]";
    } else if ([type isEqualToString:DBMessageTypeAd]) {
        
        content = @"[Ad]";
    } else if([type isEqualToString:DBMessageTypeVoice]){
        content = @"[语音]";
    }
    
    return content;
}

@end
