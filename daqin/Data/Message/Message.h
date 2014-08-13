//
//  BXMessage.h
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

typedef NS_ENUM(NSInteger, MessageType)
{
    MessageTypeText = 1,
    MessageTypeImage,
    MessageTypeState,
    MessageTypeVoice
};

typedef NS_ENUM(NSInteger, MessageFrom)
{
    MessageFromMine,
    MessageFromOther,
    MessageFromServer,
};

typedef NS_ENUM(NSInteger, MessageState)
{
    MessageStateSending,
    MessageStateSendOK,
    MessageStateSendFail,
};

@class HJAd;

@interface Message : NSObject

/**
 *  每条信息唯一的id，由server端生成
 */
@property (nonatomic,copy) NSString* guid;

/**
 *  发消息的人id
 */
@property (nonatomic,copy) NSString* fromId;

/**
 *  收消息的人id
 */
@property (nonatomic,copy) NSString* toId;

/**
 *  消息发送状态
 */
@property (nonatomic,assign) MessageState state;

/**
 *  是否已读
 */
@property (nonatomic,assign) int read;

/**
 *  消息类型
 */
@property (nonatomic,assign) MessageType type;

/**
 *  消息来源
 */
@property (nonatomic,assign) MessageFrom from;

/**
 *  消息时间
 */
@property (nonatomic,strong) NSDate* time;

/**
 *  content（json）
 */
@property (nonatomic,copy) NSString* content;

/**
 *  发送的格式
 */
@property (nonatomic,copy) NSString* contentToSend;

/**
 *  object（json）
 */
@property (nonatomic,strong) NSData* object;

/**
 *  是否显示时间
 */
@property (nonatomic,assign) BOOL   showTime;

/**
 *  消息对应头像的URL
 */
@property (nonatomic,copy) NSString* avatarUrl;

+ (Message*) createTextMessage:(NSString*)text from:(MessageFrom)from;

+ (Message*) createImageMessageWithImage:(UIImage*)image
                                 imageSize:(CGSize)size
                                  imageUrl:(NSString*)imageUrl
                                      from:(MessageFrom)from;


+ (Message*) createVoiceMessage:(NSString*)url
                        localPath:(NSString*)localPath
                         duration:(int)duration
                             from:(MessageFrom)from;

+ (Message*) createStateMessage:(NSString*)state;

+ (Message*) createMessageWithType:(NSString*)type;

- (NSString*) typeString;

- (NSString*) textValue;

- (UIImage*) imageValue;
- (NSString*) imageUrl;

+ (NSString *)jsonStringFromDic:(NSDictionary *)dic;

- (void) loadObject;

- (NSData*) objectData;

- (NSDictionary*) contentDic;

@end
