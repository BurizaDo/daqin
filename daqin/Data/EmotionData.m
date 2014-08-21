//
//  EmotionData.m
//  Baixing
//
//  Created by 王冠立 on 2/7/14.
//
//

#import "EmotionData.h"

@implementation EmotionData

- (id)init:(NSString*)emotionStr emotionImg:(NSString*)emotionImg {
    self = [super init];
    self.emotionStr = emotionStr;
    self.emotionImg = emotionImg;
    return self;
}

@end
