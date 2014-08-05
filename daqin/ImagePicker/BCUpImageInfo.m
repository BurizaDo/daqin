//
//  BCUploadImageInfo.m
//  Baixing
//
//  Created by zengming on 13-2-27.
//
//

#import "BCUpImageInfo.h"
#import "BCUpImageButton.h"
#import "Uploader.h"

@interface BCUpImageInfo ()


- (void)uploadImage;

@end

@implementation BCUpImageInfo

- (id)init
{
    self = [super init];
    if (self) {
        _status = BCUpImageNormal;
    }
    return self;
}

#pragma mark - upload image

- (void)beginUploadImage:(UIImage *)image {
    self.status = BCUpImageUploading;
    self.image = image;
    self.thumbImage = [self imageByResizeImage:image toMaxLength:kUpImageButtonEdge-kUpImageButtonPadding];

    [self.weakUpImageButton bindImageInfo:self];
    
    [self uploadImage];
}

- (void)loadWithImageUrl:(NSString*)url thumbImageUrl:(NSString*)thumbUrl;
{
    self.status = BCUpImageUploaded;
    self.url = url;
    self.thumbUrl = thumbUrl;
    [self.weakUpImageButton bindImageInfo:self];
    
    __weak BCUpImageInfo * weakSelf = self;
    
    if (url.length>0) {
                [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {

                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                    weakSelf.image = image;
                    [_weakUpImageButton.imageButton setImage:_image forState:UIControlStateNormal];
                }];
    }
    
    if (thumbUrl.length>0) {
                [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                    weakSelf.thumbImage = image;
                    [_weakUpImageButton.imageButton setImage:_thumbImage forState:UIControlStateNormal];
                }];
    }

}

- (void)uploadImage {    
    __weak BCUpImageInfo * weakSelf = self;
    
    [Uploader uploadImage:_image onSuccess:^(NSString * returnUrl) {
        weakSelf.url = returnUrl;
        weakSelf.status = BCUpImageUploaded;
        weakSelf.path = [[returnUrl stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByAppendingString:@"#up"];
        
        [self freeImage];
        
        [weakSelf.infoDelegate uploadSuccessWithUpImageInfo:weakSelf];
        
    } onFailure:^(NSString *  failure) {
        weakSelf.status = BCUpImageUploadFailed;
        [weakSelf.infoDelegate uploadFailWithUpImageInfo:weakSelf];

    } onProgress:^(CGFloat percent, long long sent) {
        [weakSelf.infoDelegate upImageInfo:weakSelf uploadProgress:percent];
    }];
}

- (void)freeImage
{
    if (self.url.length>0) {
        [[SDImageCache sharedImageCache] storeImage:self.image forKey:self.url toDisk:YES];
    }
    self.image = nil;
}

- (UIImage *)image
{
    if ( !_image && _url.length > 0 ) {
        _image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.url];
    }
    return _image;
}

#pragma mark - Image Process
- (UIImage*)imageByResizeImage:(UIImage*)image toMaxLength:(CGFloat)maxLength
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat resizeRatio = maxLength / MIN(width, height);
    CGFloat desWidth = width * resizeRatio;
    CGFloat desHeight = height * resizeRatio;
    
    UIImage *newImage;
    @autoreleasepool {
        UIGraphicsBeginImageContext(CGSizeMake(maxLength, maxLength));
        [image drawInRect:CGRectMake((maxLength - desWidth) / 2 , (maxLength - desHeight) / 2, desWidth, desHeight)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
}



@end
