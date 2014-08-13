//
//  BXMessage.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "Message.h"
#import "TextMessage.h"
#import "ImageMessage.h"
#import "StateMessage.h"
#import "VoiceMessage.h"

@implementation Message

+ (Message*) createTextMessage:(NSString*)text from:(MessageFrom)from
{
    TextMessage* message = [TextMessage new];
    
    message.text = text;
    message.from = from;
    message.state = MessageStateSending;
    message.time = [NSDate date];
    
    return message;
}


+ (Message*) createImageMessageWithImage:(UIImage*)image imageSize:(CGSize)size imageUrl:(NSString*)imageUrl from:(MessageFrom)from
{
    ImageMessage* message = [ImageMessage new];
    message.image = image;
    if (image) {
        message.imageSize = image.size;
    }
    else{
        message.imageSize = size;
    }
    message.imageUrl = imageUrl;
    message.from = from;
    message.state = MessageStateSending;
    message.time = [NSDate date];
    
    return message;
}

+ (Message*) createVoiceMessage:(NSString*)url
                            localPath:(NSString*)localPath
                                    duration:(int)duration
                             from:(MessageFrom)from{
    VoiceMessage* message = [VoiceMessage new];
    message.voiceUrl = url;
    message.localPath = localPath;
    message.duration = duration;
    message.from = from;
    message.state = MessageStateSending;
    message.time = [NSDate date];
    return message;
}


+ (Message*) createStateMessage:(NSString*)state
{
    StateMessage* message = [StateMessage new];
    message.type = MessageTypeState;
    message.stateMsg = state;
    message.from = MessageFromServer;
    message.time = [NSDate date];
    
    return message;

}

+ (Message*) createMessageWithType:(NSString*)type
{
    Message* message;
    if ([type isEqualToString:@"text"]) {
        message = [TextMessage new];
    }
    else if([type isEqualToString:@"image"]){
        message = [ImageMessage new];
    }
    else if([type isEqualToString:@"state"]){
        message = [StateMessage new];
        message.from = MessageFromServer;
    }
    else if([type isEqualToString:@"voice"]){
        message = [VoiceMessage new];
    }
    return message;
}

- (NSString*) typeString
{
    if(self.type == MessageTypeText)
    {
        return @"text";
    }
    else if(self.type == MessageTypeImage)
    {
        return @"image";
    }
    else if(self.type == MessageTypeState)
    {
        return @"state";
    }
    else if(self.type == MessageTypeVoice){
        return @"voice";
    }
    
    return @"";
}

- (NSString*) textValue
{
    if(self.type == MessageTypeText)
    {
        TextMessage* message = (TextMessage*)self;
        return message.text;
    }
    else{
        @throw [NSException exceptionWithName:@"Wrong Message Type" reason:@"must be text message" userInfo:nil];
    }
}


- (UIImage*) imageValue
{
    if(self.type == MessageTypeImage)
    {
        ImageMessage* message = (ImageMessage*)self;
        return message.image;
    }
    else{
        @throw [NSException exceptionWithName:@"Wrong Message Type" reason:@"must be image message" userInfo:nil];
    }
}

- (NSString*) imageUrl
{
    if(self.type == MessageTypeImage)
    {
        ImageMessage* message = (ImageMessage*)self;
        return message.imageUrl;
    }
    else{
        @throw [NSException exceptionWithName:@"Wrong Message Type" reason:@"must be image message" userInfo:nil];
    }
}

+ (NSString *)jsonStringFromDic:(NSDictionary *)dic
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&error];
    if (! jsonData) {
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

- (NSString*) content
{
    NSDictionary* dic = [self contentDic];
    return [Message jsonStringFromDic:dic];
}

- (NSDictionary*) contentDic
{
    @throw [NSException exceptionWithName:@"Subclass must implement contentDic" reason:@"" userInfo:nil];
    return nil;
}

- (NSString*) contentToSend
{
    NSString* type = [self typeString];
    NSDictionary* dic = @{@"content":[self contentDic],
                             @"type":type,
                             @"guid":self.guid,
                        @"fromId":self.fromId,
                          @"toId":self.toId};
    
    return [Message jsonStringFromDic:dic];
}

- (NSData*) objectData
{
    return nil;
}

- (void) loadObject
{
    
}

@end
