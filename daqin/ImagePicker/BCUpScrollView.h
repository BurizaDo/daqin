//
//  BCUpScrollView.h
//  Baixing
//
//  Created by zengming on 13-5-29.
//
//
/*
 BCUpImageInfo
 - uploadImage
 
 BCUpImageView
 -
 
 BCUpScrollView
 - addImage
 - removeImage
 
 BCUpScrollViewDelegate
 - 显示 actionSheet
 - 预览图片
 
 // todo: zengming
 */

#import <UIKit/UIKit.h>
#import "BCUpImageInfo.h"
#import "BCUpImageButton.h"

#define kUpScrollViewActionSheetTitle       @"已拍图片"

@class BCUpScrollView;

@protocol BCUpScrollViewDelegate <NSObject>

@required

- (void)upScrollView:(BCUpScrollView*)upScrollView clickedWithUpImageInfo:(BCUpImageInfo*)info;

@optional

- (void)upScrollView:(BCUpScrollView*)upScrollView longPressWithUpImageInfo:(BCUpImageInfo*)info;
- (void)upScrollViewAddButtonClicked:(BCUpScrollView*)upScrollView;

- (void)upScrollView:(BCUpScrollView*)upScrollView uploadSuccessWithUpImageInfo:(BCUpImageInfo*)info;
- (void)upScrollView:(BCUpScrollView*)upScrollView uploadFailWithUpImageInfo:(BCUpImageInfo*)info;

@end

@interface BCUpScrollView : UIScrollView

@property (strong, nonatomic) NSMutableArray *                      imageInfos;
@property (assign, nonatomic) BOOL                                  hasAddButton;

@property (weak, nonatomic) id<BCUpScrollViewDelegate>              upScrollViewDelegate;

- (void)preAddImage;
- (BOOL)addImage:(UIImage*)image;
- (void)removeImageInfo:(BCUpImageInfo*)info;

// for imageSync
- (void)addImageWithUrl:(NSString*)url;

- (BOOL)hasUploading;
- (BOOL)hasUploadFail;

- (void)syncImageUrls:(NSArray*)imageUrls;
- (void)resetImageInfos:(NSMutableArray*)imageInfos animated:(BOOL)animated;

@end
