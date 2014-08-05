//
//  BXProgressView.m
//  Baixing
//
//  Created by Zhong Jiawu on 12/17/12.
//
//

#import "ProgressView.h"
#import <QuartzCore/QuartzCore.h>


@interface BXProgressView ()

@property (nonatomic, strong) UIView *          innerView;

@end

@implementation BXProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.cornerRadius = 4;
        
        // Initialization code
        CGRect innerFrame = frame;
        innerFrame.origin.x = 2;
        innerFrame.origin.y = 2;
        innerFrame.size.width -= 4;
        innerFrame.size.height -= 4;
        _innerView = [[UIView alloc] initWithFrame:innerFrame];
        _innerView.layer.cornerRadius = 3;
        _innerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_innerView];
        
    }
    return self;
}

- (void)setProgress:(float)newProgress
{
    _progress = newProgress;
    CGRect innerFrame = _innerView.frame;
    innerFrame.size.width = _progress * (self.frame.size.width-4);
    _innerView.frame =  innerFrame;
}


@end
