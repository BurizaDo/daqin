//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "JSMessageTextView.h"

@protocol EmotionBtnDelegate
- (void) onEmotionBtnClicked;
@end

#define COMMON_PADDING 4.0F
#define COMMON_BTN_SIZE 35.0F
#define INPUT_VIEW_HEIGHT 45.0F
/**
 *  An instance of `JSMessageInputView` defines the input toolbar for composing a new message that is to be displayed above the keyboard.
 */
@interface JSMessageInputView : UIImageView

/**
 *  Returns the textView into which a new message is composed. This property is never `nil`.
 */
@property (weak, nonatomic, readonly) JSMessageTextView *textView;
@property (weak, nonatomic) UIButton *moreButton;
@property (nonatomic, weak) UIButton* audioButton;
@property (weak, nonatomic) UIButton* speakButton;
@property (nonatomic, readonly) BOOL inAudio;
@property (weak, nonatomic) UIButton* emotionButton;
@property (weak, nonatomic) id<EmotionBtnDelegate> emotionDelegate;

#pragma mark - Initialization

/**
 *  Initializes and returns an input view having the given frame, style, delegate, and panGestureRecognizer.
 *
 *  @param frame                A rectangle specifying the initial location and size of the bubble view in its superview's coordinates.
 *  @param style                The style of the input view. @see JSMessageInputViewStyle.
 *  @param delegate             An object that conforms to the `UITextViewDelegate` protocol and `JSDismissiveTextViewDelegate` protocol. 
 *  @see JSDismissiveTextViewDelegate.
 *  @param panGestureRecognizer A `UIPanGestureRecognizer` used to dismiss the input view by dragging down.
 *
 *  @return An initialized `JSMessageInputView` object or `nil` if the object could not be successfully initialized.
 */
- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<UITextViewDelegate>)delegate;

#pragma mark - Message input view

/**
 *  Adjusts the input view's frame height by the given value.
 *
 *  @param changeInHeight The delta value by which to increase or decrease the existing height for the input view.
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  @return A constant indicating the height of one line of text in the input view.
 */
+ (CGFloat)textViewLineHeight;

/**
 *  @return A contant indicating the maximum number of lines of text that can be displayed in the textView.
 */
+ (CGFloat)maxLines;

/**
 *  @return The maximum height of the input view as determined by `maxLines` and `textViewLineHeight`. This value is used for controlling the animation of the growing and shrinking of the input view as the text changes in the textView.
 */
+ (CGFloat)maxHeight;

@end