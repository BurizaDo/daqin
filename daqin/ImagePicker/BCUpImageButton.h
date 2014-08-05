//
//  BXUploadImageView.h
//  Baixing
//
//  Created by Zhong Jiawu on 12/17/12.
//
//

#import <UIKit/UIKit.h>
#import "BCUpImageInfo.h"
#import "ProgressView.h"

@class BCUpImageButton;

@protocol BCUpImageButtonDelegate <NSObject>

@required

- (void)upImageButton:(BCUpImageButton*)button clickedWithUpImageInfo:(BCUpImageInfo*)info;

@optional

- (void)upImageButton:(BCUpImageButton*)button longPressWithUpImageInfo:(BCUpImageInfo*)info;

@end


@interface BCUpImageButton : UIView

@property (strong, nonatomic) BXProgressView *                  progressView;
@property (strong, nonatomic) UIButton *                        imageButton;

@property (weak, nonatomic) id<BCUpImageButtonDelegate>         buttonDelegate;
@property (weak, nonatomic) BCUpImageInfo *                     upImageInfo;

@property (assign, nonatomic) BOOL                              isAddButton;

- (void)bindImageInfo:(BCUpImageInfo*)info;

@end
