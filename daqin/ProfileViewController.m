//
//  ProfileViewController.m
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ProfileViewController.h"
#import <UIImageView+WebCache.h>
#import "User.h"
#import "UserProvider.h"
#import "EGOCache.h"
#import "LoginViewController.h"
#import "WSAssetPickerController.h"
#import "SVProgressHUD.h"

@interface ProfileViewController () <UINavigationControllerDelegate, WSAssetPickerControllerDelegate>

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupImageScrollView:(NSArray*) imageUrls{
    CGRect frame = _imagesView.frame;
    int size = frame.size.height - 5 * 2;
    float y = 5;
    float x = 5;
    for(NSString* url in imageUrls){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, size, size)];
        x += size + 5;
        [_imagesView addSubview:iv];
        [iv sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    if(self.isEdit){
        if(imageUrls.count < 10){
            UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, size, size)];
            iv.image = [UIImage imageNamed:@"more_plus"];
            iv.userInteractionEnabled = YES;
            UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPicture)];
            [iv addGestureRecognizer:gesture];
            [_imagesView addSubview:iv];
            x += size + 5;
        }
    }
    _imagesView.contentSize = CGSizeMake(x, frame.size.height);
}

- (void)addPicture{
//    ALAssetsLibrary *libary = [[ALAssetsLibrary alloc] init];
//    WSAssetPickerController *albumPickerVC = [[WSAssetPickerController alloc] initWithAssetsLibrary:libary];
//    albumPickerVC.selectionLimit = 10 - [_user.images componentsSeparatedByString:@","].count;
//    albumPickerVC.delegate = self;
//    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [self presentViewController:albumPickerVC animated:YES completion:nil];
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        //用模式窗体转换到图片选取界面。
        UIImagePickerController *aImagePickerController = [[UIImagePickerController alloc] init];
//        aImagePickerController.delegate = self;
        aImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:aImagePickerController animated:YES completion:nil];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)edit{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *myVC = [storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
    myVC.isEdit = YES;
    myVC.title = @"编辑";
    myVC.user = _user;
    [self.navigationController pushViewController:myVC animated:YES];
}

- (void)setup{
    if([_user.avatar length] > 0){
        [_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar]];
    }
    _name.text = _user.name;
    _signature.text = _user.signature;
    _age.text = _user.age;
    if(_user.images.length > 0){
        [self setupImageScrollView:[_user.images componentsSeparatedByString:@","]];
    }
    if(_isEdit){
        _name.enabled = YES;
        _signature.enabled = YES;
        _age.enabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!_user){
        NSString* userId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
        [UserProvider getUsers:userId onSuccess:^(NSArray *users) {
            if([users count] == 0) return;
            _user = users[0];
            [self setup];
        } onFailure:^(NSString *error) {
            
        }];
    }else{
        [self setup];
    }
    if(!self.isEdit){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfile)];
    }
}

- (void)saveProfile{
    _user.name = _name.text;
    _user.age = _age.text;
    _user.signature = _signature.text;

    [SVProgressHUD showProgress:-1.0 status:@"更新中..." maskType:SVProgressHUDMaskTypeBlack];
    [UserProvider updateUser:_user onSuccess:^{
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:^{
        [SVProgressHUD dismiss];        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
