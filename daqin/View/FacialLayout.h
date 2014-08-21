//
//  FacialLayout.h
//  Baixing
//
//  Created by 王冠立 on 2/7/14.
//
//

#import <UIKit/UIKit.h>
#import "EmotionData.h"

@protocol EmotionDelegate

- (void) onEmotionSelected:(EmotionData*)emotion;

@end

@interface FacialLayout : UIView

- (void) setDelegate:(id<EmotionDelegate>)delegate;

@end
