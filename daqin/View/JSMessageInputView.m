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

#import "JSMessageInputView.h"

#import <QuartzCore/QuartzCore.h>
#import "NSString+JSMessagesView.h"
#import "UIColor+JSMessagesView.h"
#import "AudioRecorder.h"
#import "AudioPlayer.h"

@interface JSMessageInputView ()

- (void)setup;
- (void)configureInputBar;
- (void)configureMoreButton;
- (void)configureAudioButton;

@end

@implementation JSMessageInputView

@synthesize moreButton=_moreButton;

#pragma mark - Initialization

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    _inAudio = NO;
}

- (void)configureInputBar
{
    CGFloat emotionButtonWidth = 35.0F;
    CGFloat moreButtonWidth = 35.0F;
    CGFloat audioButtonWidth = 35.0F;
    CGFloat leftPadding = 4.0f;
    CGFloat rightPadding = 4.0f;
    
    CGFloat width = self.frame.size.width - moreButtonWidth - audioButtonWidth - emotionButtonWidth - leftPadding * 2- rightPadding * 4;
    CGFloat height = [JSMessageInputView textViewLineHeight];
    
    JSMessageTextView *textView = [[JSMessageTextView  alloc] initWithFrame:CGRectZero];
    textView.frame = CGRectMake(leftPadding * 2 + audioButtonWidth, 4.5f, width, height);
    textView.backgroundColor = [UIColor clearColor];
    textView.enablesReturnKeyAutomatically = YES;
    textView.returnKeyType = UIReturnKeySend;
    textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    textView.layer.borderWidth = 0.65f;
    textView.layer.cornerRadius = 6.0f;
    [self addSubview:textView];
	_textView = textView;
    
    self.image = [[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                        resizingMode:UIImageResizingModeStretch];
}

- (void) configureEmotionButton {
    UIButton* emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emotionButton setBackgroundImage:[UIImage imageNamed:@"btn_emotion"] forState:UIControlStateNormal];
    [emotionButton setBackgroundImage:[UIImage imageNamed:@"btn_emotion_HL"] forState:UIControlStateHighlighted];
    [emotionButton addTarget:self action:@selector(emotionBtnClicked) forControlEvents: UIControlEventTouchUpInside];
    
    [self setEmotionButton:emotionButton];
}

- (void) emotionBtnClicked {
    if(nil != _emotionDelegate) {
        [_emotionDelegate onEmotionBtnClicked];
    }
}

- (void)configureMoreButton
{
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"more_plus"] forState:UIControlStateNormal];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"more_plusHL"] forState:UIControlStateHighlighted];
    
    [self setMoreButton:moreButton];
}

- (void)configureAudioButton{
    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioButton setBackgroundImage:[UIImage imageNamed:@"chatting_setmode_voice_btn_normal"] forState:UIControlStateNormal];
    [audioButton setBackgroundImage:[UIImage imageNamed:@"chatting_setmode_voice_btn_pressed"] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    [self setAudioButton:audioButton];
    
    [_audioButton addTarget:self action:@selector(audioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureSpeakingButton{
    _speakButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [[UIImage imageNamed:@"btn_speak"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage* imageOn = [[UIImage imageNamed:@"btn_speak_on"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    [_speakButton setBackgroundImage:image forState:UIControlStateNormal];
    [_speakButton setBackgroundImage:imageOn forState:UIControlStateHighlighted | UIControlStateSelected];
    [_speakButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_speakButton setTitleColor:[UIColor colorWithRed:0 green:169/255.0 blue:180/255.0 alpha:1] forState:UIControlStateNormal];

	_speakButton.frame = _textView.frame;
    [self addSubview:_speakButton];
    _speakButton.hidden = YES;
}

- (void)audioButtonClicked:(UIButton *)sender{
    if(!self.inAudio){
        _textView.hidden = YES;
        _speakButton.hidden = NO;
        _inAudio = YES;
        [_audioButton setBackgroundImage:[UIImage imageNamed:@"chatting_setmode_keyboard_btn_normal"] forState:UIControlStateNormal];
        [_audioButton setBackgroundImage:[UIImage imageNamed:@"chatting_setmode_keyboard_btn_pressed"] forState:UIControlStateHighlighted | UIControlStateSelected];
        
    }else{
        _speakButton.hidden = YES;
        _textView.hidden = NO;
        _inAudio = NO;
        [_audioButton setBackgroundImage:[UIImage imageNamed:@"chatting_setmode_voice_btn_normal"] forState:UIControlStateNormal];
        [_audioButton setBackgroundImage:[UIImage imageNamed:@"chatting_setmode_voice_btn_pressed"] forState:UIControlStateHighlighted | UIControlStateSelected];
        
    }
}

- (void)setAudioButton:(UIButton *)audioButton{
    if(_audioButton){
        [_audioButton removeFromSuperview];
    }
    audioButton.frame = CGRectMake(4.0f, (self.frame.size.height - 35.0f) / 2, 35.0F, 35.0f);
    
    [self addSubview:audioButton];
    _audioButton = audioButton;
    
}

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<UITextViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self configureAudioButton];
        [self configureInputBar];
        [self configureEmotionButton];
        [self configureMoreButton];
        [self configureSpeakingButton];
        
        _textView.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    _textView = nil;
    _moreButton = nil;
    _emotionButton = nil;
}

#pragma mark - UIView

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

#pragma mark - Setters

- (void)setEmotionButton:(UIButton *)emotionButton {
    if(_emotionButton) {
        [_emotionButton removeFromSuperview];
    }
    CGRect leftRect = self.textView.frame;
    emotionButton.frame = CGRectMake(leftRect.origin.x + leftRect.size.width + COMMON_PADDING,
                                     (self.frame.size.height - COMMON_BTN_SIZE) / 2,
                                     COMMON_BTN_SIZE, COMMON_BTN_SIZE);
    [self addSubview:emotionButton];
    _emotionButton = emotionButton;
}

- (void)setMoreButton:(UIButton *)btn
{
    if (_moreButton)
        [_moreButton removeFromSuperview];
    CGRect leftRect = self.emotionButton.frame;
    btn.frame = CGRectMake(leftRect.origin.x + leftRect.size.width + COMMON_PADDING,
                           (self.frame.size.height - COMMON_BTN_SIZE) / 2,
                           COMMON_BTN_SIZE, COMMON_BTN_SIZE);
    
    [self addSubview:btn];
    _moreButton = btn;
}

- (UIButton *)moreButton
{
    return _moreButton;
}

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    NSUInteger numLines = MAX([self.textView numberOfLinesOfText],
                              [self.textView.text js_numberOfLines]);
    
    //  below iOS 7, if you set the text view frame programmatically, the KVO will continue notifying
    //  to avoid that, we are removing the observer before setting the frame and add the observer after setting frame here.
    [self.textView removeObserver:_textView.delegate
                       forKeyPath:@"contentSize"];
    
    self.textView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    [self.textView addObserver:_textView.delegate
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.textView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:NO];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 2.0f : 8.0f;
}

+ (CGFloat)maxHeight
{
    return ([JSMessageInputView maxLines] + 1.0f) * [JSMessageInputView textViewLineHeight];
}

@end
