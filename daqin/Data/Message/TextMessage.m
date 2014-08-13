//
//  BXTextMessage.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "TextMessage.h"

@implementation TextMessage

- (id)init
{
    self = [super init];
    if (self) {
        self.type = MessageTypeText;
    }
    return self;
}

- (void)setContent:(NSString*)content
{
    if (content) {
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.text = dic[@"text"];
        }
    }
}

- (NSData*) object
{
    return nil;
}

- (NSDictionary*) contentDic
{
    NSDictionary* contentDic = @{@"text":[self textValue]};
    return contentDic;
}

@end
