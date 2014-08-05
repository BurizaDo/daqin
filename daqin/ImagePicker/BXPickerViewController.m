//
//  ImagePickerViewController.m
//  Baixing
//
//  Created by Zhong Jiawu on 12/14/12.
//
//
/* TODO:
 适配 iPhone5，4
 UI
 上传逻辑剥离开来
 直接上传NSData和 存为文件再上传的内存开销


 // 问题，
 文件命名：
 uploadImageButton 删除位置
 删除按钮不一致
 拍照界面不要状态栏
 取消发布，完成拍照
 图片disable
 */

#import "BXPickerViewController.h"
#import "SDImageCache.h"
#import "ProgressView.h"
#import "UIButton+WebCache.h"
#import "BCUpScrollView.h"
#import "MWPhotoBrowser.h"

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <BlocksKit.h>
#import <SVProgressHUD.h>
#import <WSAssetPicker.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVFoundation.h>
#import "CQMFloatingController.h"
#import "BlockActionSheet.h"

#import "UIImage+Resize.h"

@interface BXPickerViewController () <BCUpScrollViewDelegate, MWPhotoBrowserDelegate, WSAssetPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIControl *        controlView;
@property (weak, nonatomic) IBOutlet BCUpScrollView *   scrollView;
@property (weak, nonatomic) IBOutlet UIView *           cameraView;
@property (weak, nonatomic) IBOutlet UIView *           whiteLightView;
@property (strong, nonatomic) IBOutlet UIButton *       titleButton;

@property (assign, nonatomic) BOOL                      isDirty;
@property (strong, nonatomic) UIButton *                naviRightButton;

@property (strong, nonatomic) BCUpImageInfo *           fuckSheetTheTempInfo;



@property (strong, nonatomic) UIImagePickerController * albumPickerVC;

@property (strong, nonatomic) ALAssetsLibrary       * library;



- (IBAction)shootButtonClicked;
- (IBAction)albumButtonClicked:(UIButton *)sender;

- (BOOL)setupTakeImage;
- (void)takeImage:(UIImage*)image;

- (BOOL)isLoadingImage;

@end

@implementation BXPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isPostFirstStep = NO;
        _isEdit = NO;
        _imageInfos = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return self;
}
#define APP_SCREEN_BOUNDS           [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT           (APP_SCREEN_BOUNDS.size.height)
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define VERSION_GREATER_7  (IOS_VERSION > 6.99)
#define kFontSizeHuge               17.0f
#define kFontSizeLarge              15.0f
#define kFontSizeMedium             14.0f
#define kFontSizeSmall              13.0f
#define kFontSizeMini               11.0f
#define kFontColorDark              [UIColor colorWithRed:0x5c/255.0 green:0x5c/255.0 blue:0x5c/255.0 alpha:1.0]

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollView.frame = CGRectMake(0, 20, 320, 69);
    self.scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width+1, _scrollView.frame.size.height);
    self.scrollView.upScrollViewDelegate = self;

    // 兼容模拟器
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.cameraPickerVC = [[UIImagePickerController alloc] init];
        _cameraPickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        _cameraPickerVC.showsCameraControls = NO;
        _cameraPickerVC.allowsEditing = NO;
        _cameraPickerVC.delegate = self;
        _cameraPickerVC.navigationBarHidden = YES;
        _cameraPickerVC.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;

        // ios 6 下 imagePicker打开的时候,镜头有动画, 加一个View 绕过去
        if (VERSION_GREATER_7 == NO) {
            UIView *subview = [[UIView alloc] initWithFrame:_cameraPickerVC.view.bounds];
            subview.backgroundColor = [UIColor blackColor];
            [_cameraPickerVC.view addSubview:subview];
            [_cameraPickerVC bk_performBlock:^(id sender) {
                dispatch_async(dispatch_get_main_queue(),^{
                    [[[_cameraPickerVC.view subviews] lastObject] removeFromSuperview];
                });
            } afterDelay:1.5f];
        }

        self.cameraView.clipsToBounds = YES;
        [self.cameraView addSubview:_cameraPickerVC.view];
        [self.cameraView sendSubviewToBack:_cameraPickerVC.view];
    }

    if (_isImageSyncStatus) {  // hide navigation right button
        [SVProgressHUD dismiss];

        self.maxPhotoCount = 8;
        self.navigationItem.titleView = _titleButton;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 70, 30);
        button.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSizeMedium];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleShadowColor:kFontColorDark forState:UIControlStateNormal];
        button.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [button addTarget:self action:@selector(dismissImageSync) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:
         [[UIImage imageNamed:@"btn_small_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]
                          forState:UIControlStateNormal];
        [button setBackgroundImage:
         [[UIImage imageNamed:@"btn_small_gray_on.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]
                          forState:UIControlStateHighlighted];

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    } else {
        if (VERSION_GREATER_7) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成拍照" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelfInPostForm)];
        }
        else{
            self.naviRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _naviRightButton.frame = CGRectMake(0, 0, 70, 30);
            [_naviRightButton setTitleShadowColor:kFontColorDark forState:UIControlStateNormal];
            _naviRightButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
            _naviRightButton.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSizeMedium];
            
            [_naviRightButton setBackgroundImage:
             [[UIImage imageNamed:@"btn_small_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]
                                        forState:UIControlStateNormal];
            [_naviRightButton setBackgroundImage:
             [[UIImage imageNamed:@"btn_small_green_on.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]
                                        forState:UIControlStateHighlighted];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButton];
            if (_isPostFirstStep) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 0, 70, 30);
                button.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSizeMedium];
                [button setTitle:@"取消发布" forState:UIControlStateNormal];
                [button setTitleShadowColor:kFontColorDark forState:UIControlStateNormal];
                button.titleLabel.shadowOffset = CGSizeMake(0, 1);
                [button addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
                [button setBackgroundImage:
                 [[UIImage imageNamed:@"btn_small_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]
                                  forState:UIControlStateNormal];
                [button setBackgroundImage:
                 [[UIImage imageNamed:@"btn_small_gray_on.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)]
                                  forState:UIControlStateHighlighted];
                
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
                
                [_naviRightButton setTitle:@"跳过拍照" forState:UIControlStateNormal];
                [_naviRightButton addTarget:self action:@selector(toPostFormStep)
                           forControlEvents:UIControlEventTouchUpInside];
            } else {
                [_naviRightButton setTitle:@"完成拍照" forState:UIControlStateNormal];
                [_naviRightButton addTarget:self action:@selector(dismissSelfInPostForm)
                           forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x48/255.0 green:0x48/255.0 blue:0x48/255.0 alpha:1.0];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0x48/255.0 green:0x48/255.0 blue:0x48/255.0 alpha:1.0];
    }
    self.navigationController.navigationBar.clipsToBounds = YES;

    [self.scrollView resetImageInfos:self.imageInfos animated:YES];
    
    self.view.backgroundColor = [UIColor blackColor];

}

- (void)viewDidUnload {
    [self setScrollView:nil];

    [self setCameraView:nil];
    [self setWhiteLightView:nil];
    [self setTitleButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!VERSION_GREATER_7) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *from = @"postForm";
    if (_isPostFirstStep) {
        if (_imageInfos.count == 0 && !_isImageSyncStatus) {
            [SVProgressHUD showSuccessWithStatus:@"免费发布，请先拍张照片！"];
        }
        from = @"others";
    }


}

- (void)dismissSelf
{
    if ([self isLoadingImage]) {
        return;
    }

    if (_isDirty)
    {
        BlockActionSheet *actionsheet = [[BlockActionSheet alloc] initWithTitle:@"退出拍照？已添加照片将不再保存"];
        [actionsheet setDestructiveButtonWithTitle:@"确认" block:^{
            if ([self isLoadingImage] == NO) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [actionsheet setCancelButtonWithTitle:@"取消" block:nil];
        [actionsheet showInView:self.view];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dismissImageSync
{
    __block BXPickerViewController *weakSelf = self;
    void (^cancelImageSyncBlock)() = ^{
        self.isImageSyncStatus = NO;
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };

    NSString *confirm = @"";
    confirm = _scrollView.hasUploading ? @"放弃上传中的图片？" : nil;
    if (confirm.length > 0) {
        BlockActionSheet *as = [[BlockActionSheet alloc] initWithTitle:confirm];
        [as setDestructiveButtonWithTitle:@"确定" block:cancelImageSyncBlock];
        [as setCancelButtonWithTitle:@"取消" block:nil];
        [as showInView:self.view];
    } else {
        cancelImageSyncBlock();
    }

}

- (void)dismissSelfInPostForm {
    if ([self isLoadingImage]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(pickerViewController:didPickImages:)]) {
        [self.delegate pickerViewController:self didPickImages:self.imageInfos];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toPostFormStep {
    if ([self isLoadingImage]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(pickerViewController:didPickImages:)]) {
        [self.delegate pickerViewController:self didPickImages:self.imageInfos];
    }
}

#pragma mark - shoot photo
#define kIsFromAlbum                @"IsFromAlbum"
#define IsFromAlbumYes              @"1"
#define IsFromAlbumNo               @"0"

- (IBAction)shootButtonClicked
{
    if (VERSION_GREATER_7) {
        AVAuthorizationStatus cameraState = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (cameraState == AVAuthorizationStatusDenied) {
            [SVProgressHUD showErrorWithStatus:@"相机功能已被禁用，请到设置-隐私-相机中修改"];
            return;
        }
    }

    if ([self isLoadingImage]) {
        return;
    }

    // 闪光灯效果
    _whiteLightView.hidden = NO;
    _whiteLightView.alpha = 0.9;
    [UIView animateWithDuration:0.8 animations:^{
        _whiteLightView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _whiteLightView.hidden = YES;
    }];

    if ([self setupTakeImage]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [_cameraPickerVC takePicture];
        } else { // for simulator
            UIImage *simImage = [UIImage imageNamed:@"Public_Body_Btn_Orange.png"];

            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self cropAndUploadImg:simImage metadata:@{kIsFromAlbum:IsFromAlbumNo}];
            });

        }
    }
}

- (BOOL)setupTakeImage
{
    // 必须等一张图片处理完成再拍照下一张图片
    if (self.imageInfos.count >= _maxPhotoCount) { // 计数以 self.imageInfos 为准
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"图片个数已达上限 %d 个", _maxPhotoCount]];
        return NO;
    }

    self.isDirty = YES;         // will take image

    [self.scrollView preAddImage];
    return YES;
}

- (void)takeImage:(UIImage*)image
{
    if (!_isImageSyncStatus && _isPostFirstStep) {
        NSString *rightButtonTitle = _imageInfos.count > 0 ? @"完成拍照" : @"跳过拍照";
        [_naviRightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
        _isDirty = _imageInfos.count > 0;
    }

    if ([self.scrollView addImage:image] == NO) {
        [SVProgressHUD showErrorWithStatus:@"添加图片失败"];
        return;
    }

    if (!_isImageSyncStatus && _imageInfos.count < _maxPhotoCount) {
        int lessCount = _maxPhotoCount - _imageInfos.count;
        NSString *msg = [NSString stringWithFormat:@"再来一张吧，你还能添加 %d 张", lessCount];
        [SVProgressHUD showSuccessWithStatus:msg];
    }

    if (!_isImageSyncStatus && _isPostFirstStep && _imageInfos.count >= _maxPhotoCount) {
        [SVProgressHUD showSuccessWithStatus:@"自动进入填写信息界面"];
        [self performSelector:@selector(toPostFormStep) withObject:nil afterDelay:1];
    }
}

- (BOOL)isLoadingImage {
    for (BCUpImageInfo *info in _imageInfos) {
        if (info.status == BCUpImageNormal) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - album action

- (IBAction)albumButtonClicked:(UIButton *)sender
{
    if ([self isLoadingImage]) {
        return;
    }

    
    NSInteger remain = _maxPhotoCount - [_imageInfos count];
    if (remain <= 0) {
        NSString *msg = [NSString stringWithFormat:@"图片个数已达上限 %d 个", _maxPhotoCount];
        [SVProgressHUD showErrorWithStatus: msg];
        return;
    }

    ALAssetsLibrary *libary = [[ALAssetsLibrary alloc] init];
    self.library = libary;
    WSAssetPickerController *albumPickerVC = [[WSAssetPickerController alloc] initWithAssetsLibrary:libary];
    albumPickerVC.selectionLimit = remain;
    albumPickerVC.delegate = self;

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self presentViewController:albumPickerVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerViewControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker == _cameraPickerVC) {

        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSMutableDictionary *metadata = [[info valueForKey:UIImagePickerControllerMediaMetadata] mutableCopy];


        @autoreleasepool {
            CGFloat smallSideLength = MIN(image.size.width, image.size.height);
            image = [self imageByCropping:image toRect:CGRectMake(0, 0, smallSideLength, smallSideLength)];
        }

        [metadata setObject:IsFromAlbumNo forKey:kIsFromAlbum];

        [self cropAndUploadImg:image metadata:metadata];
    } else if (picker == _albumPickerVC) {
        UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __block NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithObject:IsFromAlbumYes forKey:kIsFromAlbum];
        [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
            [picker dismissViewControllerAnimated:YES completion:nil];
            [self setupTakeImage];
            ALAssetRepresentation *reps = [asset defaultRepresentation];
            [metadata addEntriesFromDictionary:reps.metadata];
            [self cropAndUploadImg:image metadata:metadata];
        } failureBlock:^(NSError *error) {
            [picker dismissViewControllerAnimated:YES completion:nil];
            [self setupTakeImage];
            [self cropAndUploadImg:image metadata:metadata];
        }];
    }

}

- (void)cropAndUploadImg:(UIImage *)image metadata:(NSDictionary *)metadata {
    if (image) {
        @autoreleasepool {
            image = [image bx_imageResizetoMaxLength:640];
            [self takeImage:image];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"获取图片失败"];
    }
}

#pragma mark WSAssetPickerController Delegate methods

- (void)assetPickerControllerDidCancel:(WSAssetPickerController *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)assetPickerController:(WSAssetPickerController *)picker didFinishPickingMediaWithAssets:(NSArray *)assets
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithObject:IsFromAlbumYes forKey:kIsFromAlbum];

        for (ALAsset *asset in assets) {
            [self setupTakeImage];
            UIImage *image = [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullScreenImage];
            ALAssetRepresentation *reps = [asset defaultRepresentation];
            [metadata addEntriesFromDictionary:reps.metadata];
            [self cropAndUploadImg:image metadata:metadata];
        }
    }];
}

- (void)assetPickerControllerDidLimitSelection:(WSAssetPickerController *)sender
{
    NSString *msg = [NSString stringWithFormat:@"图片个数已达上限 %d 个", _maxPhotoCount];
    [SVProgressHUD showErrorWithStatus: msg];
}

#pragma mark - Image Process

- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:[imageToCrop imageOrientation]];
    CGImageRelease(imageRef);
    return cropped;
}

- (void)presentSelfFrom:(UIViewController*)viewController animated:(BOOL)animated {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    [nav.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if (!VERSION_GREATER_7) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    [viewController presentViewController:nav animated:YES completion:nil];
}

- (void)sendCurrentImageUrls
{
    NSMutableArray *imageUrls = [NSMutableArray array];
    [self.imageInfos enumerateObjectsUsingBlock:^(BCUpImageInfo* info, NSUInteger idx, BOOL *stop) {
        if (info.status == BCUpImageUploaded) {
            [imageUrls addObject:info.url];
        }
    }];
}


#pragma mark - BCUpScrollViewDelegate

- (void)upScrollView:(BCUpScrollView*)upScrollView uploadSuccessWithUpImageInfo:(BCUpImageInfo*)info;
{
    [self sendCurrentImageUrls];
}


// 重复 PickerVC-PostAdVC

- (void)upScrollView:(BCUpScrollView *)upScrollView clickedWithUpImageInfo:(BCUpImageInfo *)info
{
    if (info.status == BCUpImageNormal
        || info.status == BCUpImageUploading
        || info.status == BCUpImageUploaded ) {
        self.fuckSheetTheTempInfo = info;
        BlockActionSheet *actionsheet = [[BlockActionSheet alloc] initWithTitle:kUpScrollViewActionSheetTitle];
        [actionsheet addButtonWithTitle:@"查看" block:^{
            [self showImagesPreview];
        }];
        [actionsheet setDestructiveButtonWithTitle:@"删除" block:^{
            [self.scrollView removeImageInfo:_fuckSheetTheTempInfo];
            
            [self sendCurrentImageUrls];
            if (_isPostFirstStep == YES) {
                NSString *rightButtonTitle = _imageInfos.count > 0 ? @"完成拍照" : @"跳过拍照";
                [_naviRightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
                _isDirty = _imageInfos.count > 0;
            }
        }];
        [actionsheet setCancelButtonWithTitle:@"取消" block:nil];
        [actionsheet showInView: self.view];
    } else if (info.status == BCUpImageUploadFailed) {
        [info beginUploadImage:info.image];
    }
}

- (void)upScrollView:(BCUpScrollView *)upScrollView uploadFailWithUpImageInfo:(BCUpImageInfo *)info
{
    [SVProgressHUD showErrorWithStatus:@"上传失败，点击图片重试"];
}

#pragma mark - private

- (void)showImagesPreview
{
    int idx = [self.imageInfos indexOfObject:_fuckSheetTheTempInfo];

    MWPhotoBrowser *imgBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    imgBrowser.displayActionButton = YES;
    imgBrowser.wantsFullScreenLayout = YES;
    imgBrowser.zoomPhotosToFill = YES;
    [imgBrowser setCurrentPhotoIndex:idx];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imgBrowser];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
{
    return _imageInfos.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
{
    BCUpImageInfo *info = self.imageInfos[index];
    MWPhoto *p = [MWPhoto photoWithImage:info.image];
    return p;
}

// 重复 PickerVC-PostAdVC end

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
