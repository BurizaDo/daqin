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
#import "ProfileView.h"
#import "SettingCell.h"
#import "ListingViewController.h"

@interface ProfileViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) ProfileView* headerView;
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
        [_headerView.avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar]];
    }
    [_headerView.avatar.layer setCornerRadius:CGRectGetHeight(_headerView.avatar.bounds)/2];
    _headerView.avatar.layer.masksToBounds = YES;
    _headerView.name.text = _user.name;
    CGSize maximumLabelSize = CGSizeMake(999,999);
    CGSize expectedLabelSize = [_headerView.name.text sizeWithFont:_headerView.name.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:_headerView.name.lineBreakMode];
    float totalWidth = _headerView.age.frame.size.width + expectedLabelSize.width + 3;
    CGRect nameRect = CGRectMake((320 - totalWidth)/2, _headerView.name.frame.origin.y, expectedLabelSize.width, _headerView.name.frame.size.height);
    _headerView.name.frame = nameRect;
    
    CGRect ageFrame = _headerView.age.frame;
    ageFrame.origin.x = nameRect.origin.x + nameRect.size.width + 3;
    _headerView.age.frame = ageFrame;
    _headerView.age.layer.cornerRadius = _headerView.age.bounds.size.height / 2;
    UIColor* colorF = [UIColor colorWithRed:255/255.0 green:172/255.0 blue:184/255.0 alpha:1];
    UIColor* colorM = [UIColor colorWithRed:172/255.0 green:215/255.0 blue:255/255.0 alpha:1];
    if([_user.gender isEqualToString:@"男"]){
        _headerView.age.backgroundColor = colorM;
    }else{
        _headerView.age.backgroundColor = colorF;
    }
    _headerView.age.text = _user.age;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _headerView = [[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:nil options:nil][0];
    self.tableView.tableHeaderView = _headerView;
    // Do any additional setup after loading the view.
    if(!_user){
        [self loadUser];
    }else{
        [self setup];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setup) name:@"profileChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewUser) name:@"qqUserGot" object:nil];
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人资料" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
}

- (void)edit{
    ProfileEditViewController* edit = [[ProfileEditViewController alloc] initWithNibName:@"ProfileEditViewController" bundle:nil];
    edit.title = @"个人资料";
    edit.user = _user;
    [self.navigationController pushViewController:edit animated:YES];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return 3;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 20;
    return 10.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kSettingCell"];
    if (!cell) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil];
        cell = nib[0];
        cell.rightArrowHidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(indexPath.section == 0){
        cell.name.text = @"已发布的行程";
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            cell.name.text = @"发送反馈";
        }else if(indexPath.row == 1){
            cell.name.text = @"检查更新";
        }else if(indexPath.row == 2){
            cell.name.text = @"推送设置";
        }
    }else if(indexPath.section == 2){
        cell.name.text = @"退出登录";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ListingViewController *listingVC = (ListingViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ListingVC"];
        listingVC.isMyListing = YES;
        [self.navigationController pushViewController:listingVC animated:YES];

    }else if(indexPath.section == 2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认退出"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"退出", nil];
        [alert show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [[EGOCache globalCache] removeCacheForKey:@"userToken"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didlogout" object:nil];
    }
}

@end
