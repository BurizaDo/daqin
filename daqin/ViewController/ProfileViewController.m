//
//  ProfileViewController.m
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ProfileViewController.h"
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

@interface ProfileViewController () <UINavigationControllerDelegate, WSAssetPickerControllerDelegate, BXPickerViewControllerDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray* allImages;

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
        [btn sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [_imagesView addSubview:btn];
    }
    if(self.isEdit){
        if(imageUrls.count < 10){
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(x, y, size, size);
            [btn setImage:[UIImage imageNamed:@"more_plus"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(addPicture) forControlEvents:UIControlEventTouchUpInside];
            [_imagesView addSubview:btn];
            x += size + 5;
        }
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
    if(_isEdit){
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
    }else{
        [self showBigPicture:btn.tag];
    }
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
            [[QQHelper sharedInstance] getUserInfo];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(!_user){
        [self loadUser];
    }else{
        [self setup];
    }
    if(!_isEdit){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileChanged) name:@"profileChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewUser) name:@"qqUserGot" object:nil];
        
    }
}

- (void)createNewUser{
    NSLog(@"createNewUser");
    User* user = [GlobalDataManager sharedInstance].user;
    NSLog(@"call updateUser");

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
//    if(!_user){
//        NSString* userId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
//        [UserProvider getUsers:userId onSuccess:^(NSArray *users) {
//            if([users count] == 0) return;
//            _user = users[0];
//            [self setup];
//        } onFailure:^(NSString *error) {
//            
//        }];
//    }else{
//        [self setup];
//    }
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
    if(_user.images.length > 0){
        _user.images = [_user.images stringByAppendingString:@","];
    }
    _user.images = [_allImages componentsJoinedByString:@","];
    
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
