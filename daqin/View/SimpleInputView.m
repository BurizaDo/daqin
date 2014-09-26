//
//  SimpleInputView.m
//  daqin
//
//  Created by BurizaDo on 9/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "SimpleInputView.h"

@interface SimpleInputView() <UITextViewDelegate>

@end
@implementation SimpleInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, frame.size.width - 20, frame.size.height - 10)];
        [self addSubview:_textView];
        _textView.layer.cornerRadius = 6.0f;
        _textView.layer.masksToBounds = YES;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeySend;
        self.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if(_messageDelegate){
            [_messageDelegate onSendMessage:textView.text];
            self.textView.text = nil;
        }
        return NO;
    }
    return  YES;
}

@end
