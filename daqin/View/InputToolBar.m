//
//  InputToolBar.m
//  Baixing
//
//  Created by 王冠立 on 1/7/14.
//
//

#import "InputToolBar.h"
#import "FacialLayout.h"
#import "EmotionUtil.h"

@interface InputToolBar()<EmotionBtnDelegate, EmotionDelegate, UITextViewDelegate>

@property (nonatomic, retain, readonly) UIView* superView;
@property (nonatomic, readonly) FacialLayout* facialLayout;

@property (nonatomic, assign) BOOL keyboardIsShow;
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
// 之所以需要设这个变量，是因为当toolbar控件变大时，inputlayout也会变高适应（UIViewAutoresizingFlexibleHeight）
@property (nonatomic, assign) CGFloat inputLayoutHeight;
@property (nonatomic, assign) BOOL showEmotion;

@end

@implementation InputToolBar

- (instancetype) initWithFrame:(CGRect)frame
                     superView:(UIView *)superView {
    _superView = superView;
    self = [super initWithFrame:frame];
    if(nil != self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        self.opaque = YES;
        self.userInteractionEnabled = YES;
        
        _inputLayout = [[JSMessageInputView alloc]
                        initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, INPUT_VIEW_HEIGHT)
                        delegate:self];
        [_inputLayout setEmotionDelegate:self];
        _inputLayoutHeight = INPUT_VIEW_HEIGHT;
        [self addSubview:_inputLayout];
        _textView = _inputLayout.textView;
        
        _facialLayout = [[FacialLayout alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, frame.size.width, keyboardHeight)];
        [_facialLayout setDelegate:self];
        [_facialLayout setHidden:YES];
        [self addSubview:_facialLayout];
        _showEmotion = YES;
    }
    return self;
}

- (void) setDelegate:(id<InputToolBarDelegate>)delegate {
    _delegate = delegate;
    [self setupDelegate];
}

- (void) endEditing {
    [UIView animateWithDuration:Time animations:^{
        self.frame = CGRectMake(0, self.superView.frame.size.height - _inputLayoutHeight, self.superView.bounds.size.width,
                                _inputLayoutHeight);
    }];
    [self hideFacialLayout];
}

- (void) setupDelegate {
    [_inputLayout.moreButton addTarget:self action:@selector(onMoreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_inputLayout.audioButton addTarget:self.delegate action:@selector(audioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_inputLayout.speakButton addTarget:self.delegate action:@selector(speakButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_inputLayout.speakButton addTarget:self.delegate action:@selector(speakButtonUp:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) onMoreBtnClicked:(UIButton*)sender {
    NSString* str = _inputLayout.textView.text;
    if(nil == _delegate) {
        return;
    }
    if(nil == str || 0 == [str length]) {
        [_delegate moreButtonClicked:sender];
    }
    else {
        [_delegate onSendTextMessage:str];
    }
}

- (void) onEmotionBtnClicked {
    //如果直接点击表情，通过toolbar的位置来判断
    CGRect rc = self.frame;
    CGRect rc1 = self.superView.frame;
//    if (self.frame.origin.y == self.superView.frame.size.height - _inputLayoutHeight && self.frame.size.height == _inputLayoutHeight) {
    if(_showEmotion){

        [UIView animateWithDuration:Time animations:^{
            self.frame = CGRectMake(0, self.superView.frame.size.height - keyboardHeight - _inputLayoutHeight, self.superView.bounds.size.width, keyboardHeight + _inputLayoutHeight);
        }];
        [_inputLayout resignFirstResponder];
        [self showFacialLayout];
        _showEmotion = NO;
        
    }
    else {
        _showEmotion = YES;
        //如果键盘没有显示，点击表情了，隐藏表情，显示键盘
        if (!_keyboardIsShow) {
            [self hideFacialLayout];
            [_inputLayout becomeFirstResponder];
        }
        else{
        //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
            [UIView animateWithDuration:Time animations:^{
                self.frame = CGRectMake(0, self.superView.frame.size.height - keyboardHeight - _inputLayoutHeight, self.superView.bounds.size.width, keyboardHeight + _inputLayoutHeight);
            }];
            [self showFacialLayout];
            [_inputLayout resignFirstResponder];
        }
    }
    if(nil != _delegate) {
        [_delegate onInputing];
    }
}

- (void) onEmotionSelected:(EmotionData*)emotion {
    if(nil == emotion) {
        return;
    }
    // delete
    if([EmotionUtil isDelEmotion:emotion]) {
        [InputToolBar textView:_inputLayout.textView handleDelete:[_inputLayout.textView.text length]];
    }
    // select emotion
    else {
        _inputLayout.textView.text = [_inputLayout.textView.text stringByAppendingString:emotion.emotionStr];
    }
}

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification {
    _keyboardIsShow = YES;
    self.frame = CGRectMake(0, self.frame.origin.y, self.superView.bounds.size.width,
                            _inputLayoutHeight);
    [self hideFacialLayout];
    _showEmotion = YES;
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification {
    _keyboardIsShow = NO;
}

#pragma mark - hide/show emotion panel

- (void)hideFacialLayout {
    [UIView animateWithDuration:Time animations:^{
        [_facialLayout setFrame:CGRectMake(0, self.superView.frame.size.height,
                                           self.superView.frame.size.width,
                                           keyboardHeight)];
        [_facialLayout setHidden:YES];
        [_inputLayout.emotionButton setBackgroundImage:[UIImage imageNamed:@"btn_emotion"] forState:UIControlStateNormal];
        [_inputLayout.emotionButton setBackgroundImage:[UIImage imageNamed:@"btn_emotion_HL"] forState:UIControlStateHighlighted];
    }];
}

- (void)showFacialLayout {
    [UIView animateWithDuration:Time animations:^{
        [_facialLayout setFrame:CGRectMake(0, _inputLayoutHeight, self.frame.size.width, keyboardHeight)];
        [_facialLayout setHidden:NO];
        [_inputLayout.emotionButton setBackgroundImage:
         [UIImage imageNamed:@"chatting_setmode_keyboard_btn_normal"] forState:UIControlStateNormal];
        [_inputLayout.emotionButton setBackgroundImage:
         [UIImage imageNamed:@"chatting_setmode_keyboard_btn_pressed"] forState:UIControlStateHighlighted];
    }];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.textView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

#pragma mark 输入框大小变化的监听

- (void) registerTextViewObserver {
    [self.textView addObserver:self
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
}

- (void) unregisterTextViewObserver {
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView
{
    CGFloat maxHeight = [JSMessageInputView maxHeight];
    
    BOOL isShrinking = textView.contentSize.height < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textView.contentSize.height - self.previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        
        changeInHeight = 0;
        
    } else {
        /**
         *  不知道为啥拿到的textView的contentSize.height的值不对, 有想法的同学过来解决下???
         */
        if (abs(changeInHeight) == 24) {
            return;
        } else {
            changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
        }
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^
         {
             if(nil != _delegate) {
                 [_delegate inputLayoutResized:changeInHeight];
             }
             
             if (isShrinking) {
                 // if shrinking the view, animate text view frame BEFORE input view frame
                 [self.inputLayout adjustTextViewHeightBy:changeInHeight];
             }
             
             CGRect inputViewFrame = self.frame;
             self.frame = CGRectMake(0.0f,
                                     inputViewFrame.origin.y - changeInHeight,
                                     inputViewFrame.size.width,
                                     inputViewFrame.size.height + changeInHeight);
             if (!isShrinking) {
                 // growing the view, animate the text view frame AFTER input view frame
                 [self.inputLayout adjustTextViewHeightBy:changeInHeight];
             }
             _inputLayoutHeight += changeInHeight;
             // reset frame of facial layout
             [_facialLayout setFrame:CGRectMake(0, _inputLayoutHeight, self.frame.size.width, keyboardHeight)];
         } completion:^(BOOL finished) {
         }];
        
        self.previousTextViewContentHeight = MIN(textView.contentSize.height, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           CGPoint bottomOffset = CGPointMake(0.0f, textView.contentSize.height - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

#pragma mark - uitextview delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.previousTextViewContentHeight) {
		self.previousTextViewContentHeight = textView.contentSize.height;
    }
    if(nil != _delegate) {
        [_delegate onInputing];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if(nil != _delegate) {
            [_delegate onSendTextMessage:self.textView.text];
        }
        return NO;
    }
    else if(0 < [textView.text length] && 1 == range.length && [text isEqualToString:@""]) {
        [InputToolBar textView:textView handleDelete:(range.location + 1)];
        return NO;
    }
    return  YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString* str = textView.text;
    if(nil == str || 0 == [str length]) {
        [_inputLayout.moreButton setBackgroundImage:[UIImage imageNamed:@"more_plus"] forState:UIControlStateNormal];
        [_inputLayout.moreButton setBackgroundImage:[UIImage imageNamed:@"more_plusHL"] forState:UIControlStateHighlighted];
    }
    else {
        [_inputLayout.moreButton setBackgroundImage:[UIImage imageNamed:@"btn_send"] forState:UIControlStateNormal];
        [_inputLayout.moreButton setBackgroundImage:[UIImage imageNamed:@"btn_send"] forState:UIControlStateHighlighted];
    }
}

+ (void)textView:(UITextView *)textView handleDelete:(NSUInteger)location {
    NSString* str = textView.text;
    NSArray* matches = [EmotionUtil findEmojiInStr:str range:NSMakeRange(0, location)];
    NSRange deleteRange = NSMakeRange(location - 1, 1);
    if(nil != matches && 0 != [matches count]) {
        NSTextCheckingResult* lastMatch = [matches objectAtIndex:[matches count] - 1];
        if(nil != lastMatch
           && location == (lastMatch.range.location + lastMatch.range.length)) {
            EmotionData* emotion = [EmotionUtil findEmotionByStr:[str substringWithRange:lastMatch.range]];
            if(nil != emotion) {
                deleteRange = lastMatch.range;
            }
        }
    }
    textView.text = [str stringByReplacingCharactersInRange:deleteRange withString:@""];
}

@end
