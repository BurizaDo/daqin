//
//  BXMessageInfo.m
//  Baixing
//
//  Created by neoman on 5/20/14.
//
//

#import "MessageInfo.h"

static NSArray *testNames = nil;
static NSArray *messages = nil;

@implementation MessageInfo

+ (void)initialize
{
    testNames = @[@"小老百姓卖二手", @"御版美琴", @"百姓网官微"];
    messages = @[@"不好意思, 已经卖掉了", @"还在的, 你要吗??", @"对不起, 下雨去不了"];
}

+ (instancetype)randomMessageInfo
{
    NSUInteger random = arc4random_uniform(3);
    NSString *name = testNames[random];
    NSString *message = messages[random];
    
    MessageInfo *messageInfo = [MessageInfo new];
    messageInfo.name = name;
    messageInfo.content = message;
    messageInfo.timeStamp = [NSDate dateWithTimeIntervalSince1970:arc4random_uniform(3000000)];
    messageInfo.badgeCount = arc4random_uniform(10);
    
    return messageInfo;
}

@end
