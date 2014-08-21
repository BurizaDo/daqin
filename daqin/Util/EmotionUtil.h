//
//  EmotionUtil.h
//  Baixing
//
//  Created by 王冠立 on 2/7/14.
//
//

#import <Foundation/Foundation.h>
#import "EmotionData.h"

@interface EmotionUtil : NSObject

+ (NSMutableArray*) getAllEmotions;
+ (BOOL) isDelEmotion:(EmotionData*)data;
+ (EmotionData*) findEmotionByStr:(NSString*)str;
+ (NSArray*) findEmojiInStr:(NSString*)str range:(NSRange)range;
@end
