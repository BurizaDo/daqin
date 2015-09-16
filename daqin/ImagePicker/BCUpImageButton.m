//
//  BXUploadImageView.m
//  Baixing
//
//  Created by Zhong Jiawu on 12/17/12.
//
//  状态：1.正常   2.上传中，有进度条（或者activityIndicator+文字）    2.上传失败，有重试和提供文字

#import "BCUpImageButton.h"
#import "ProgressView.h"
#import <UIButton+WebCache.h>
#import "SVProgressHUD.h"

@interface BCUpImageButton()

@end



@implementation BCUpImageButton


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self buildSubViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews
{
    self.clipsToBounds = NO;
    
    CGRect rect = self.bounds;
    
    UIImage *bgImage = [UIImage imageNamed:@"Post_Body_Btn_Pic"];
    rect.size = bgImage.size;
    rect.origin.x -= 2;
    rect.origin.y -= 1;
    
//    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:rect];
//    bgImageView.image = bgImage;
//    [self addSubview:bgImageView];
    
    self.imageButton = [[UIButton alloc] initWithFrame:
                        CGRectMake(kUpImageButtonPadding,
                                   kUpImageButtonPadding,
                                   self.bounds.size.width-kUpImageButtonPadding*2,
                                   self.bounds.size.height-kUpImageButtonPadding*2)];
    _imageButton.backgroundColor = [UIColor grayColor];
    [_imageButton addTarget:self
                     action:@selector(imageButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_imageButton];
    
    CGSize whiteSize = self.frame.size;
    
    self.progressView = [[BXProgressView alloc] initWithFrame:CGRectMake(0, 0, whiteSize.width-16, 10)];
    _progressView.progress = 0;
    _progressView.center = CGPointMake(whiteSize.width/2, whiteSize.height/2);
    _progressView.userInteractionEnabled = NO;
    _progressView.hidden = YES;
    
    [self addSubview:_progressView];
    
    UILongPressGestureRecognizer *pressGes =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(imageButtonLongPressGesture)];
    [self.imageButton addGestureRecognizer:pressGes];
}

- (void)imageButtonClicked
{
    [self.buttonDelegate upImageButton:self clickedWithUpImageInfo:self.upImageInfo];
}

- (void)imageButtonLongPressGesture
{
    if ([self.buttonDelegate respondsToSelector:@selector(upImageButton:longPressWithUpImageInfo:)]) {
        [self.buttonDelegate upImageButton:self longPressWithUpImageInfo:self.upImageInfo];      
    }
}

- (void)bindImageInfo:(BCUpImageInfo*)info;
{
    self.upImageInfo = info;
    self.upImageInfo.weakUpImageButton = self;
    
    [self.imageButton setImage:self.upImageInfo.thumbImage ?: _upImageInfo.image forState:UIControlStateNormal];

    if (!_upImageInfo.image && !_upImageInfo.thumbImage && info.url) {
        [self.imageButton setImageWithURL:[NSURL URLWithString:info.url] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:@"网络异常，加载图片失败"];
            } else {
                info.thumbImage = image;
                info.thumbUrl = nil;
            }
        }];
    }
    // reset all
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
    
    switch (info.status) {
        case BCUpImageNormal: {
            self.progressView.hidden = NO;
            break;
        }
        case BCUpImageUploading: {
            self.progressView.hidden = NO;
            break;
        }
        case BCUpImageUploaded: {
            break;
        }
        case BCUpImageUploadFailed: {
            [self.imageButton setImage:[UIImage imageNamed:@"Vad_Body_Icon_FailedPic.png"]
                              forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

- (void)setIsAddButton:(BOOL)isAddButton
{
    _isAddButton = isAddButton;
    if (_isAddButton) {
        [self.imageButton setImage:[UIImage imageNamed:@"Post_Body_Btn_Add_Pic@2x"]
                          forState:UIControlStateNormal];
        [self.imageButton setImage:[UIImage imageNamed:@"Post_Body_Btn_Add_Pic_On@2x"]
                          forState:UIControlStateHighlighted];
    }
}

@end
