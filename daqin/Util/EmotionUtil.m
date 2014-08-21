//
//  EmotionUtil.m
//  Baixing
//
//  Created by 王冠立 on 2/7/14.
//
//

#import "EmotionUtil.h"
#import "EmotionData.h"

@implementation EmotionUtil

static NSMutableArray* emotions = nil;
static NSMutableDictionary* dic = nil;


+ (NSMutableArray*) getAllEmotions {
    [EmotionUtil init];
    return emotions;
}

+ (void) init {
    if(nil == emotions || nil == dic) {
        emotions = [[NSMutableArray alloc] init];
        
        [EmotionUtil addEmotionData:emotions emotionStr:@"[红脸笑]" emotionImg:@"emoji_1"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[开口笑]" emotionImg:@"emoji_2"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[失望]" emotionImg:@"emoji_3"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[瞪]" emotionImg:@"emoji_4"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[鬼脸]" emotionImg:@"emoji_5"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[色]" emotionImg:@"emoji_6"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[惊叫]" emotionImg:@"emoji_7"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[汗]" emotionImg:@"emoji_8"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[恶魔]" emotionImg:@"emoji_9"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[强壮]" emotionImg:@"emoji_10"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[心]" emotionImg:@"emoji_12"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[遗憾]" emotionImg:@"emoji_13"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[奸笑]" emotionImg:@"emoji_14"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[哀愁]" emotionImg:@"emoji_15"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[龇牙]" emotionImg:@"emoji_16"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[眨眼]" emotionImg:@"emoji_17"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[坚持]" emotionImg:@"emoji_18"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[讨厌]" emotionImg:@"emoji_19"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[困]" emotionImg:@"emoji_20"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[吐舌]" emotionImg:@"emoji_21"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[轻松]" emotionImg:@"emoji_22"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[害怕]" emotionImg:@"emoji_23"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[口罩]" emotionImg:@"emoji_24"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[脸红]" emotionImg:@"emoji_25"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[不好笑]" emotionImg:@"emoji_26"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[冷汗张嘴]" emotionImg:@"emoji_27"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[惊呆]" emotionImg:@"emoji_28"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[大哭]" emotionImg:@"emoji_29"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[泪笑]" emotionImg:@"emoji_30"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[可怜哭]" emotionImg:@"emoji_31"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[甜甜笑]" emotionImg:@"emoji_32"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[开口憨笑]" emotionImg:@"emoji_33"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[怒红脸]" emotionImg:@"emoji_34"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[闭眼吻]" emotionImg:@"emoji_35"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[飞吻]" emotionImg:@"emoji_36"];
        [EmotionUtil addEmotionData:emotions emotionStr:@"[DEL]" emotionImg:@"emoji_del"];
        
        dic = [[NSMutableDictionary alloc] init];
        for(EmotionData* data in emotions) {
            [dic setObject:data forKey:data.emotionStr];
        }
    }
}

+ (void) addEmotionData:(NSMutableArray*)array emotionStr:(NSString*)emotionStr emotionImg:(NSString*)emotionImg {
    if(nil == array) {
        return;
    }
    [array addObject:[[EmotionData alloc] init:emotionStr emotionImg:emotionImg]];
}

+ (BOOL) isDelEmotion:(EmotionData*)data {
    if(nil == data) {
        return NO;
    }
    if([@"[DEL]" isEqual:[data emotionStr]]) {
        return YES;
    }
    return NO;
}

+ (EmotionData*) findEmotionByStr:(NSString*)str {
    [EmotionUtil init];
    return [dic valueForKey:str];
}

+ (NSArray*) findEmojiInStr:(NSString*)str range:(NSRange)range {
    NSString* regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regex_emoji
                                                                           options:0
                                                                             error:nil];
    return [regex matchesInString:str options:0 range:range];
}

@end
