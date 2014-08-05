//
//  BlockBackground.m
//  arrived
//
//  Created by Gustavo Ambrozio on 29/11/11.
//  Copyright (c) 2011 N/A. All rights reserved.
//

#import "BlockBackground.h"

UIImage * getGradientImage(CGSize size);

@interface BlockBackground ()
{
    UIWindow *_previousKeyWindow;
}

@end

@implementation BlockBackground

static BlockBackground *_sharedInstance = nil;

+ (BlockBackground*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)setRotation:(NSNotification*)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    
    if(
       (UIInterfaceOrientationIsLandscape(orientation) && orientationFrame.size.height > orientationFrame.size.width) ||
       (UIInterfaceOrientationIsPortrait(orientation) && orientationFrame.size.width > orientationFrame.size.height)
       ) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
    }
    
    self.transform = CGAffineTransformIdentity;
    self.frame = orientationFrame;
    
    CGFloat posY = orientationFrame.size.height/2;
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    self.transform = CGAffineTransformMakeRotation(rotateAngle);
    self.center = newCenter;
    
    [self setNeedsLayout];
    [self layoutSubviews];
}

- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar;
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.vignetteBackground = NO;
        
        UIImageView *back = [[UIImageView alloc] initWithFrame:self.bounds];
        back.image = getGradientImage(self.bounds.size);
        self.backgroundView = back;
        [self addSubview:back];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setRotation:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        [self setRotation:nil];

    }
    return self;
}

- (void)addToMainWindow:(UIView *)view
{
    [self setRotation:nil];
    
    if ([self.subviews containsObject:view]) return;

    if (self.hidden)
    {
        _previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
        self.backgroundView.alpha = 0.0f;
        self.hidden = NO;
        [self makeKeyWindow];
    }
    
    // if something's been added to this window, then this window should have interaction
    self.userInteractionEnabled = YES;
    
    if (self.subviews.count > 0)
    {
        ((UIView*)[self.subviews lastObject]).userInteractionEnabled = NO;
    }
    
    [self addSubview:view];
}

- (void)removeView:(UIView *)view
{
    [view removeFromSuperview];
    self.hidden = YES;
    [_previousKeyWindow makeKeyWindow];
    _previousKeyWindow = nil;
}

@end

UIImage * getGradientImage(CGSize size)
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
	CGFloat locations[2] = {0.0f, 1.0f};
	CGFloat colors[8] = {0.0f,0.0f,0.0f,0.15f,0.0f,0.0f,0.0f,0.75f};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
	CGColorSpaceRelease(colorSpace);
	
	CGPoint center = CGPointMake(size.width/2, size.height/2);
	float radius = MIN(size.width , size.height) ;
	CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImg;
}