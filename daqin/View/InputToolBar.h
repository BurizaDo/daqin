//
//  InputToolBar.h
//  Baixing
//
//  Created by 王冠立 on 1/7/14.
//
//

#import <UIKit/UIKit.h>
#import "JSMessageInputView.h"

@protocol keyboardDelegate
- (void)handleWillShowKeyboardNotification:(NSNotification *)notification;
- (void)handleWillHideKeyboardNotification:(NSNotification *)notification;
@end

@protocol InputToolBarDelegate

- (void) moreButtonClicked:(UIButton *)sender;
- (void) audioButtonClicked:(UIButton*)sender;
- (void) speakButtonDown:(UIButton*)sender;
- (void) speakButtonUp:(UIButton*)sender;

- (void) onInputing;
- (void) onSendTextMessage:(NSString*)txt;
// 抱歉，没看懂这段调坐标的逻辑，变量名先按逻辑里边的变量名来了
- (void) inputLayoutResized:(CGFloat)changeInHeight;

@end

#define Time  0.25
#define  keyboardHeight 216

@interface InputToolBar : UIImageView<keyboardDelegate>

@property (nonatomic) id<InputToolBarDelegate> delegate;
@property (weak, nonatomic, readonly) JSMessageTextView* textView;
@property (nonatomic, readonly) JSMessageInputView* inputLayout;

- (instancetype)initWithFrame:(CGRect)frame
                    superView:(UIView *)superView;

- (void) endEditing;
- (void) registerTextViewObserver;
- (void) unregisterTextViewObserver;

@end
