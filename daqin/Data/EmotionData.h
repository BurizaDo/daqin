//
//  EmotionData.h
//  Baixing
//
//  Created by 王冠立 on 2/7/14.
//
//

#import <Foundation/Foundation.h>

@interface EmotionData : NSObject

@property (nonatomic, retain) NSString* emotionStr;
@property (nonatomic, retain) NSString* emotionImg;

- (id)init:(NSString*)emotionStr emotionImg:(NSString*)emotionImg;

@end
