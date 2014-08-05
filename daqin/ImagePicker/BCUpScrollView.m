//
//  BCUpScrollView.m
//  Baixing
//
//  Created by zengming on 13-5-29.
//
//

#import "BCUpScrollView.h"
#define kAnimationDurationLonger    0.7f
#define kAnimationDurationLong      0.45f
#define APP_SCREEN_BOUNDS           [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT           (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH            (APP_SCREEN_BOUNDS.size.width)


@interface BCUpScrollView ()  <BCUpImageInfoDelegate, BCUpImageButtonDelegate>

@property (strong, nonatomic) BCUpImageButton *         addButton;

@end

@implementation BCUpScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.clipsToBounds = NO;
}

- (void)relayoutAndScrollWithAnimated:(BOOL)animated
{
    int buttonCount = _hasAddButton ? _imageInfos.count + 1 : _imageInfos.count;
    [self relayoutAndScrollWithAnimated:animated scrollToIndex:(buttonCount-1)];
}

- (void)relayoutAndScrollWithAnimated:(BOOL)animated scrollToIndex:(int)idx
{
    NSTimeInterval duration = animated ? kAnimationDurationLonger : 0;
    int buttonCount = _hasAddButton ? _imageInfos.count + 1 : _imageInfos.count;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
    {
        // relayout
        CGRect lastRect = kUpImageButtonFrameAtIndex(buttonCount-1);
        float contentSizeWidth = MAX(321, lastRect.origin.x+lastRect.size.width+kUpSCrollViewPaddingRight);
        self.contentSize = CGSizeMake(contentSizeWidth, self.bounds.size.height);
        
        __block CGRect btnRect;
        [_imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo* info, NSUInteger idx, BOOL *stop) {
            btnRect = kUpImageButtonFrameAtIndex(idx);
            BCUpImageButton * upImageButton = info.weakUpImageButton;
            if (upImageButton) {
                upImageButton.frame = btnRect;
            }
        }];
        
        if (_hasAddButton) {
            self.addButton.frame = lastRect;
        }
        
        // scroll
        CGRect showRect = kUpImageButtonFrameAtIndex(idx);
        if (idx != 0) {
            showRect.origin.x -= kUpSCrollViewPaddingLeft * 3;
            showRect.size.width += kUpSCrollViewPaddingRight + kUpSCrollViewPaddingLeft * 3;
        }
        [self scrollRectToVisible:showRect animated:NO];
        
    } completion:nil];
}

- (void)preAddImage;
{
    BCUpImageInfo *imageInfo = [[BCUpImageInfo alloc] init];
    imageInfo.infoDelegate = self;
    [self.imageInfos addObject:imageInfo];
    [self addUpImageButtonWithInfo:imageInfo index:_imageInfos.count-1];
    
    [self relayoutAndScrollWithAnimated:YES];
}

- (BOOL)addImage:(UIImage*)image;
{
    BCUpImageInfo *info = nil;
    for (BCUpImageInfo *each in _imageInfos) {
        if (each.status == BCUpImageNormal) {
            info = each;
            break;
        }
    }
    if (!info) {
        return NO;
    }
    [info beginUploadImage:image];
    return YES;
}

- (void)removeImageInfo:(BCUpImageInfo*)info;
{
    int showIdx = [_imageInfos indexOfObject:info];
    [_imageInfos removeObject:info];
    
    [self relayoutAndScrollWithAnimated:YES scrollToIndex:showIdx]; // scroll to want delete index.
    
    [UIView animateWithDuration:kAnimationDurationLong
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        CGRect rect = info.weakUpImageButton.frame;
        rect.origin.y -= 100;
        info.weakUpImageButton.frame = rect;
        info.weakUpImageButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [info.weakUpImageButton removeFromSuperview];
        [self relayoutAndScrollWithAnimated:YES scrollToIndex:showIdx];
    }];
}

- (void)syncImageUrls:(NSArray*)imageUrls
{
    NSMutableArray *removeInfos = [NSMutableArray array];
    NSMutableArray *addUrls = [NSMutableArray array];
    NSMutableArray *loadingInfos = [NSMutableArray array];
    NSMutableArray *newImageInfos = [NSMutableArray array];

    // 加载中的 info 用 loadingInfos 缓存起来
    for (int i=0; i<_imageInfos.count; i++) {
        BCUpImageInfo *info = _imageInfos[i];
        if (info.status != BCUpImageUploaded) {
            [loadingInfos addObject:info];
            [_imageInfos removeObject:info];
            i--;
        }
    }

    // 找旧的重复的 info 放到 newInfos, 本地不存在的 url，放到 addUrls 缓存
    [imageUrls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
        BCUpImageInfo *info = [self findImageInfoByImageUrl:url];
        if (info) {
            [newImageInfos addObject:info];
            [_imageInfos removeObject:info];
        } else {
            [addUrls addObject:url];
        }
    }];
    
    // 旧的剩余的 info 加到 removeInfos 缓存
    [_imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo *info, NSUInteger idx, BOOL *stop) {
        if ([newImageInfos containsObject:info] == NO) {
            [removeInfos addObject:info];
        }
    }];
    
    
    [removeInfos enumerateObjectsUsingBlock:^(BCUpImageInfo *info, NSUInteger idx, BOOL *stop) {
        [self removeImageInfo:info];
    }];
    
    self.imageInfos = newImageInfos;
    
    [addUrls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
        [self addImageWithUrl:url];
    }];
    
    [self.imageInfos addObjectsFromArray:loadingInfos];
    
    [UIView animateWithDuration:kAnimationDurationLong animations:^{
        [_imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo *info, NSUInteger idx, BOOL *stop) {
            info.weakUpImageButton.frame = kUpImageButtonFrameAtIndex(idx);
        }];
    }];
}

- (BCUpImageInfo*)findImageInfoByImageUrl:(NSString*)url
{
    __block BCUpImageInfo *result = nil;
    [_imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo *info, NSUInteger idx, BOOL *stop) {
        if ([url isEqualToString:info.url]) {
            result = info;
            *stop = YES;
            return;
        } else {
            NSRange r = [info.url rangeOfString:@"/.+\\.(jpg|jpeg|png|gif)$" options:NSRegularExpressionSearch];
            if (r.location != NSNotFound) { // 是又拍传下来的 /xxxx.jpg 类型的 url
                r = [url rangeOfString:info.url];
                if (r.location != NSNotFound) { // info.url, url 内容一致
                    info.url = url;
                    result = info;
                    *stop = YES;
                    return;
                }
            }
        }
    }];
    
    return result;
}

- (void)resetImageInfos:(NSMutableArray*)imageInfos animated:(BOOL)animated;
{
    // clear subviews
    [self.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    self.imageInfos = imageInfos;
    
    [_imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo* info, NSUInteger idx, BOOL *stop) {
        info.infoDelegate = self;
        [self addUpImageButtonWithInfo:info index:idx];
    }];
    
    if (_hasAddButton) {
        CGRect rect = kUpImageButtonFrameAtIndex(_imageInfos.count);
        rect.origin.x += _imageInfos.count > 0 ? APP_SCREEN_WIDTH : 0;      // 没有图片时 addButton 不动画显示
        self.addButton.frame = rect;
        [self addSubview:self.addButton];
    }
    
    [self relayoutAndScrollWithAnimated:animated]; // todo ming 删除时 scroll 位置不对
}

- (void)addUpImageButtonWithInfo:(BCUpImageInfo*)info index:(int)idx
{
    CGRect beginRect = kUpImageButtonFrameAtIndex(idx);
    beginRect.origin.x += APP_SCREEN_WIDTH;
    
    BCUpImageButton *imageButton = [[BCUpImageButton alloc] initWithFrame:beginRect];
    imageButton.buttonDelegate = self;
    [imageButton bindImageInfo:info];
    
    [self addSubview:imageButton];
}

// for imageSync
- (void)addImageWithUrl:(NSString*)url;
{
    BCUpImageInfo *imageInfo = [[BCUpImageInfo alloc] init];
    imageInfo.infoDelegate = self;
    [self.imageInfos addObject:imageInfo];
    [self addUpImageButtonWithInfo:imageInfo index:_imageInfos.count-1];
    
    [self relayoutAndScrollWithAnimated:YES];
    
    [imageInfo loadWithImageUrl:url thumbImageUrl:nil];
}

#pragma mark - BCUploadImageInfoDelegate

- (void)uploadSuccessWithUpImageInfo:(BCUpImageInfo *)info
{
    [info.weakUpImageButton bindImageInfo:info];
    if ([self.upScrollViewDelegate respondsToSelector:@selector(upScrollView:uploadSuccessWithUpImageInfo:)]) {
        [self.upScrollViewDelegate upScrollView:self uploadSuccessWithUpImageInfo:info];
    }
}

- (void)uploadFailWithUpImageInfo:(BCUpImageInfo *)info
{
    [info.weakUpImageButton bindImageInfo:info];
    if ([self.upScrollViewDelegate respondsToSelector:@selector(upScrollView:uploadFailWithUpImageInfo:)]) {
        [self.upScrollViewDelegate upScrollView:self uploadFailWithUpImageInfo:info];
    }
}

- (void)upImageInfo:(BCUpImageInfo *)info uploadProgress:(float)progress
{
    info.weakUpImageButton.progressView.progress = progress;
    if ([self.upScrollViewDelegate respondsToSelector:@selector(upScrollView:longPressWithUpImageInfo::)]) {
        [self.upScrollViewDelegate upScrollView:self longPressWithUpImageInfo:info];
    }
}

#pragma mark - BXUploadImageButtonDelegate

- (void)upImageButton:(BCUpImageButton *)button clickedWithUpImageInfo:(BCUpImageInfo *)info
{
    if (button.isAddButton) {
        [self.upScrollViewDelegate upScrollViewAddButtonClicked:self];
        return;
    }
    
    [self.upScrollViewDelegate upScrollView:self clickedWithUpImageInfo:info];
}

- (void)upImageButton:(BCUpImageButton *)button longPressWithUpImageInfo:(BCUpImageInfo *)info
{
    if ([self.upScrollViewDelegate respondsToSelector:@selector(upScrollView:longPressWithUpImageInfo:)]) {
        [self.upScrollViewDelegate upScrollView:self longPressWithUpImageInfo:info];
    }
}

#pragma mark- private

- (BCUpImageButton *)addButton
{
    if (!_addButton) {
        _addButton = [[BCUpImageButton alloc] initWithFrame:CGRectMake(0, 0, kUpImageButtonEdge, kUpImageButtonEdge)];
        _addButton.buttonDelegate = self;
        _addButton.isAddButton = YES;
    }
    return _addButton;
}

- (void)setHasAddButton:(BOOL)hasAddButton
{
    _hasAddButton = hasAddButton;
    [self resetImageInfos:_imageInfos animated:NO];
}

- (BOOL)hasUploading;
{
    __block BOOL has = NO;
    [_imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo *info, NSUInteger idx, BOOL *stop) {
        if (info.status == BCUpImageUploading || info.status == BCUpImageNormal) {
            has = YES;
            *stop = YES;
        }
    }];
    return has;
}

- (BOOL)hasUploadFail;
{
    __block BOOL has = NO;
    [_imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo *info, NSUInteger idx, BOOL *stop) {
        if (info.status == BCUpImageUploadFailed) {
            has = YES;
            *stop = YES;
        }
    }];
    return has;
}

@end
