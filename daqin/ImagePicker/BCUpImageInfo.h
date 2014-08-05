//
//  BCUploadImageInfo.h
//  Baixing
//
//  Created by zengming on 13-2-27.
//
//

#import <Foundation/Foundation.h>

#import "ProgressView.h"
#import <SDWebImage/SDWebImageManager.h>

#define kUpScrollViewHeight         109
#define kUpSCrollViewPaddingLeft    10
#define kUpSCrollViewPaddingRight   10
#define kUpSCrollViewPaddingTop     0

#define kUpImageButtonPadding       2
#define kUpImageButtonEdge          67
#define kUpImageButtonSpace         10

#define kUpImageButtonFrameAtIndex(index)   \
    CGRectMake( kUpSCrollViewPaddingLeft+(kUpImageButtonEdge+kUpImageButtonSpace)*(index),      \
        kUpSCrollViewPaddingTop,    \
        kUpImageButtonEdge,    \
        kUpImageButtonEdge)

typedef enum
{
    BCUpImageNormal         = 0,
    BCUpImageUploading      = 1,
    BCUpImageUploaded       = 2,
    BCUpImageUploadFailed   = 3
} BCUpImageStatus;

@class BCUpImageInfo;
@class BCUpImageButton;

@protocol BCUpImageInfoDelegate <NSObject>

@required

- (void)uploadSuccessWithUpImageInfo:(BCUpImageInfo*)info;
- (void)uploadFailWithUpImageInfo:(BCUpImageInfo*)info;

@optional

- (void)upImageInfo:(BCUpImageInfo*)info uploadProgress:(float)progress;

@end

@interface BCUpImageInfo : NSObject

@property (weak, nonatomic)     id<BCUpImageInfoDelegate>   infoDelegate;
@property (weak, nonatomic)     BCUpImageButton *           weakUpImageButton;

@property (strong, nonatomic)   UIImage *                       image;          //开始上传后 image 会释放掉
@property (strong, nonatomic)   UIImage *                       thumbImage;     //显示请使用 thumbImage
@property (assign, nonatomic)   BCUpImageStatus             status;

@property (strong, nonatomic)   NSString *                      url;
@property (strong, nonatomic)   NSString *                      thumbUrl;
@property (strong, nonatomic)   NSString *                      path;

// bind uploadProgressView, setThumbImage, upload image.        for post view
- (void)beginUploadImage:(UIImage*)image;

// for edit view
- (void)loadWithImageUrl:(NSString*)url thumbImageUrl:(NSString*)thumbUrl;

@end
