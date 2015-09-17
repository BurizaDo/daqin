
//
//  ProfileViewController.m
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ProfileEditViewController.h"
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import "User.h"
#import "UserProvider.h"
#import "EGOCache.h"
#import "LoginViewController.h"
#import "WSAssetPickerController.h"
#import "SVProgressHUD.h"
#import "BXPickerViewController.h"
#import "BCUpImageInfo.h"
#import "BlockActionSheet.h"
#import "MWPhotoBrowser.h"
#import "GlobalDataManager.h"
#import "ChatSession.h"
#import "ChatUser.h"
#import "QQHelper.h"
#import "GlobalDataManager.h"
#import "ViewUtil.h"
#import <UIKit/UIApplication.h>
#import "Uploader.h"
#import "UIImage+Resize.h"

@interface ProfileEditViewController () <UINavigationControllerDelegate, WSAssetPickerControllerDelegate, BXPickerViewControllerDelegate, MWPhotoBrowserDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray* allImages;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@end

@implementation ProfileEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(backAction)];
    }
    return self;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideKeyboard{
    [_name resignFirstResponder];
    [_age resignFirstResponder];
    [_signature resignFirstResponder];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideKeyboard];
}

- (void)setupImageScrollView:(NSArray*) imageUrls{
    [[_imagesView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGRect frame = _imagesView.frame;
    int size = frame.size.height - 5 * 2;
    float y = 5;
    float x = 5;
    for(int i = 0; i < imageUrls.count; ++ i){
        NSString* url = imageUrls[i];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, size, size);
        x += size + 5;
        [[btn layer] setCornerRadius:4.0];
        [btn layer].masksToBounds = YES;
        [btn setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];        
        [btn addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [_imagesView addSubview:btn];
    }
    if(imageUrls.count < 10){
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, size, size);
        [btn setImage:[UIImage imageNamed:@"more_plus"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addPicture) forControlEvents:UIControlEventTouchUpInside];
        [_imagesView addSubview:btn];
        x += size + 5;
    }
    _imagesView.contentSize = CGSizeMake(x, frame.size.height);
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return _allImages.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    NSString* url = _allImages[index];
    return [MWPhoto photoWithURL:[NSURL URLWithString:url]];
}

- (void)showBigPicture:(int)index{
    MWPhotoBrowser *imgBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    imgBrowser.displayActionButton = YES;
    imgBrowser.wantsFullScreenLayout = YES;
    imgBrowser.zoomPhotosToFill = YES;
    [imgBrowser setCurrentPhotoIndex:index];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imgBrowser];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)imageClicked:(id)sender{
    UIButton* btn = sender;
    BlockActionSheet* sheet = [[BlockActionSheet alloc] init];
    [sheet addButtonWithTitle:@"查看" atIndex:0 block:^{
        [self showBigPicture:btn.tag];
    }];
    [sheet addButtonWithTitle:@"删除" atIndex:1 block:^{
        [_allImages removeObjectAtIndex:btn.tag];
        [self setupImageScrollView:_allImages];
    }];
    [sheet setCancelButtonWithTitle:@"取消" atIndex:2 block:^{
        
    }];
    [sheet showInView:self.view];
}

- (void)pickerViewController:(BXPickerViewController*)picker didPickImages:(NSMutableArray*)imageInfos{
    for(BCUpImageInfo* image in imageInfos){
        if(image.url){
            [_allImages addObject:image.url];
        }
    }
    [self setupImageScrollView:_allImages];
}


- (void)addPicture{
    BXPickerViewController *pickerVC = [[BXPickerViewController alloc] init];
    pickerVC.delegate = self;
    pickerVC.maxPhotoCount = 9 - [_user.images componentsSeparatedByString:@","].count;
    [pickerVC presentSelfFrom:self animated:YES];
    
}

- (void)loadUser{
    NSLog(@"loadUser");
    NSString* userId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
    [UserProvider getUsers:userId onSuccess:^(NSArray *users) {
        if([users count] == 0) return;
        self.user = users[0];
        [GlobalDataManager sharedInstance].user = self.user;
        ChatUser* selfUser = [[ChatUser alloc] initWithPeerId:self.user.userId displayName:self.user.name iconUrl:self.user.avatar];
        [[ChatSession sharedInstance] enableChat:selfUser];
        [self setup];
    } onFailure:^(Error *error) {
        if(error.errorCode){
//            [[QQHelper sharedInstance] getUserInfo];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setup];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [_scrollView addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)createNewUser{
    User* user = [GlobalDataManager sharedInstance].user;
    
    [UserProvider updateUser:user onSuccess:^{
        NSLog(@"updateUser Succeeded");
        _user = user;
        [self loadUser];
    } onFailure:^(Error *error) {
        
    }];
}

- (void)setUser:(User *)user{
    _user = user;
    _allImages = [[NSMutableArray alloc] init];
    if(_user.images.length > 0){
        [_allImages addObjectsFromArray:[_user.images componentsSeparatedByString:@","]];
    }
}

- (void)profileChanged{
    [self setup];
}

- (void)setup{
    if([_user.avatar length] > 0){
        [_avatar setImageWithURL:[NSURL URLWithString:_user.avatar]];
    }
    [_avatar.layer setCornerRadius:CGRectGetHeight(_avatar.bounds)/2];
    _avatar.layer.masksToBounds = YES;
    _scrollView.delegate = self;
    _name.text = _user.name;
    _signature.text = _user.signature;
    _age.text = _user.age;
    [self setupImageScrollView:[_user.images componentsSeparatedByString:@","]];
    if(_user.gender.length > 0){
        if([_user.gender isEqualToString:@"男"]){
            _genderSeg.selectedSegmentIndex = 0;
        }else{
            _genderSeg.selectedSegmentIndex = 1;
        }
    }
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTap:)];

    [_avatar addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleAvatarTap:(id)sender{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"选择照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 2) return;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    UIImagePickerControllerSourceType source = (buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera
                                              : UIImagePickerControllerSourceTypeSavedPhotosAlbum);
    if ([UIImagePickerController isSourceTypeAvailable:source] ) {
        imagePickerController.sourceType = source;
        imagePickerController.allowsEditing = YES;
        [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - uiimagepickercontroller delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    UIImage *image = info[UIImagePickerControllerEditedImage];
    image = [image bx_imageResizetoMaxLength:300];
    [image bx_imageResizetoMaxLength:300];

    [Uploader uploadImage:image onSuccess:^(NSString * fileUrl) {
        _user.avatar = fileUrl;
        _avatar.image = image;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } onFailure:^(NSString * error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } onProgress:^(CGFloat percent, long long sent) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissModalViewControllerAnimated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfile)];
    float y = _imagesView.frame.origin.y + _imagesView.frame.size.height + 15;
    CGRect superRect = [_scrollView superview].frame;
    _scrollView.contentSize = CGSizeMake(superRect.size.width, y);
    _scrollView.frame = CGRectMake(0, 0, superRect.size.width, superRect.size.height);

}

- (void)saveProfile{
    _user.name = _name.text;
    _user.age = _age.text;
    _user.signature = _signature.text;
    if(_user.images.length > 0){
        _user.images = [_user.images stringByAppendingString:@","];
    }
    _user.images = [_allImages componentsJoinedByString:@","];
    if(_genderSeg.selectedSegmentIndex == 0){
        _user.gender = @"男";
    }else{
        _user.gender = @"女";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileChanged" object:nil];
    
    [SVProgressHUD showProgress:-1.0 status:@"更新中..." maskType:SVProgressHUDMaskTypeBlack];
    [UserProvider updateUser:_user onSuccess:^{
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:^(Error* error){
        [SVProgressHUD dismiss];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
