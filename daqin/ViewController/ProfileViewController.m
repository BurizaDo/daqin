//
//  ProfileViewController.m
//  daqin
//
//  Created by BurizaDo on 8/18/14.
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
#import "ProfileEditViewController.h"

@interface ProfileViewController () <MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray* allImages;
@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* age;
@property (nonatomic, weak) IBOutlet UILabel* signature;
@property (nonatomic, weak) IBOutlet UIScrollView* imagesView;
@property (nonatomic, weak) IBOutlet UIImageView* mask;

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

- (void)setup{
    if([_user.avatar length] > 0){
        [_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar]];
    }
    [_avatar.layer setCornerRadius:CGRectGetHeight(_avatar.bounds)/2];
    _avatar.layer.masksToBounds = YES;
    _name.text = _user.name;
    CGSize maximumLabelSize = CGSizeMake(999,999);
    CGSize expectedLabelSize = [_name.text sizeWithFont:_name.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:_name.lineBreakMode];
    float totalWidth = _age.frame.size.width + expectedLabelSize.width + 3;
    CGRect nameRect = CGRectMake((320 - totalWidth)/2, _name.frame.origin.y, expectedLabelSize.width, _name.frame.size.height);
    _name.frame = nameRect;
    
    CGRect ageFrame = _age.frame;
    ageFrame.origin.x = nameRect.origin.x + nameRect.size.width + 3;
    _age.frame = ageFrame;
    _age.layer.cornerRadius = _age.bounds.size.height / 2;
    UIColor* colorF = [UIColor colorWithRed:255/255.0 green:172/255.0 blue:184/255.0 alpha:1];
    UIColor* colorM = [UIColor colorWithRed:172/255.0 green:215/255.0 blue:255/255.0 alpha:1];
    if([_user.gender isEqualToString:@"男"]){
        _age.backgroundColor = colorM;
    }else{
        _age.backgroundColor = colorF;
    }
    

    _signature.text = _user.signature;
    _age.text = _user.age;
    if(_user.images.length > 0){
        [self setupImageScrollView:[_user.images componentsSeparatedByString:@","]];
    }
}

- (void)imageClicked:(id)sender{
    UIButton* btn = sender;
    [self showBigPicture:btn.tag];
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
        [btn sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [btn addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [_imagesView addSubview:btn];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!_user){
        [self loadUser];
    }else{
        [self setup];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setup) name:@"profileChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewUser) name:@"qqUserGot" object:nil];
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
}

- (void)edit{
    ProfileEditViewController* edit = [[ProfileEditViewController alloc] initWithNibName:@"ProfileEditViewController" bundle:nil];
    edit.title = @"编辑";
    edit.user = _user;
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)setUser:(User *)user{
    _user = user;
    _allImages = [[NSMutableArray alloc] init];
    if(_user.images.length > 0){
        [_allImages addObjectsFromArray:[_user.images componentsSeparatedByString:@","]];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    float width = [UIScreen mainScreen].bounds.size.width;
    
    self.avatar.frame = CGRectMake((width - 90)/2, 20, 90, 90);
    _mask.frame = CGRectMake((width - 108)/2, 11, 108, 108);
    _name.frame = CGRectMake(_name.frame.origin.x, 11 + 108 + 5, _name.frame.size.width, _name.frame.size.height);
    _age.frame = CGRectMake(_age.frame.origin.x, 11 + 108 + 10, _age.frame.size.width, _age.frame.size.height);
    _signature.frame = CGRectMake(_signature.frame.origin.x, 11 + 108 + 10 + _age.frame.size.height + 10, _signature.frame.size.width, _signature.frame.size.height);
    _imagesView.frame = CGRectMake(0, _signature.frame.origin.y + _signature.frame.size.height + 30, width, _imagesView.frame.size.height);
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
