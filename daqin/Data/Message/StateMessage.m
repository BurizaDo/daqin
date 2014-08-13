//
//  BXStateMessage.m
//  Baixing
//
//  Created by minjie on 14-5-16.
//
//

#import "StateMessage.h"

@implementation StateMessage

- (id)init
{
    self = [super init];
    if (self) {
        self.type = MessageTypeState;
    }
    return self;
}

- (void)setContent:(NSString*)content
{
    if (content) {
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.stateMsg = dic[@"text"];
        }
    }
}

- (NSDictionary*) contentDic
{
    NSDictionary* contentDic = @{@"text":self.stateMsg};
    return contentDic;
}

@end
