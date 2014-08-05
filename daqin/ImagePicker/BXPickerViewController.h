//
//  ImagePickerViewController.h
//  Baixing
//
//  Created by Zhong Jiawu on 12/14/12.
//
//

#import <UIKit/UIKit.h>


@class BXPickerViewController;

@protocol BXPickerViewControllerDelegate <NSObject>

- (void)pickerViewController:(BXPickerViewController*)picker didPickImages:(NSMutableArray*)imageInfos;

@end

@interface BXPickerViewController : UIViewController <UINavigationControllerDelegate,
                                                         UIImagePickerControllerDelegate>

@property (assign, nonatomic) id<BXPickerViewControllerDelegate>    delegate;
@property (strong, nonatomic) NSMutableArray *                      imageInfos;
@property (strong, nonatomic) UIImagePickerController *             cameraPickerVC;
@property (assign, nonatomic) BOOL                                  isPostFirstStep;
@property (assign, nonatomic) BOOL                                  isEdit;
@property (assign, nonatomic) BOOL                                  isImageSyncStatus;
@property (assign, nonatomic) int                       maxPhotoCount;

- (void)presentSelfFrom:(UIViewController*)viewController animated:(BOOL)animated;

@end
