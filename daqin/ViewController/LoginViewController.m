//
//  LoginViewController.m
//  daqin
//
//  Created by BurizaDo on 7/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "LoginViewController.h"
#import "QQHelper.h"
#import "EGOCache.h"
#import "WeiboSDK.h"
#import "LoginManager.h"
#import "UserProvider.h"
#import "ChatUser.h"
#import "GlobalDataManager.h"
#import "ChatSession.h"
#import "ViewUtil.h"
#import "RegisterViewController.h"
#import "SVProgressHUD.h"
#import "UserProvider.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *account;

@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *selfLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *thirdPartyLabel;



@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)simulateLogin{
    [[EGOCache globalCache] setObject:@"123" forKey:@"userToken"];
    [UserProvider getUsers:@"123" onSuccess:^(NSArray *users) {
        if([users count] == 0) return;
        User* user = users[0];
        [GlobalDataManager sharedInstance].user = user;
        ChatUser* selfUser = [[ChatUser alloc] initWithPeerId:user.userId displayName:user.name iconUrl:user.avatar];
        [[ChatSession sharedInstance] enableChat:selfUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil];
    } onFailure:^(Error *error) {
    }];
    
}

- (void)loginClicked{
    if (TARGET_IPHONE_SIMULATOR){
        [self simulateLogin];
    }else{
        [[LoginManager sharedInstance] loginQQ];
    }
}

- (void)weiboLogin{
    if (TARGET_IPHONE_SIMULATOR){
        [[LoginManager sharedInstance] loginWeibo];        
//        [self simulateLogin];
    }else{
        [[LoginManager sharedInstance] loginWeibo];
    }
    
}

- (void)handleLoginSucceed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"登录";
    [self.loginBtn addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.weiboLoginBtn addTarget:self action:@selector(weiboLogin) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSucceed) name:@"loginSucceed" object:nil];
    if(_hasBack){
        self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(handleBack)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleBordered target:self action:@selector(doRegister)];
    
    UIGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFocus)];
    [self.view addGestureRecognizer:gesture];
    [_selfLoginButton addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)isEmpty:(NSString*)string{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0;
}

- (void)doLogin{
    if([self isEmpty:_account.text]){
        [SVProgressHUD showErrorWithStatus:@"请填写用户名"];
        return;
    }
    if([self isEmpty:_password.text]){
        [SVProgressHUD showErrorWithStatus:@"请填写密码"];
        return;
    }
    [UserProvider login:_account.text password:_password.text onSuccess:^(id object) {
        NSDictionary* result = object;
        User* user = [[User alloc] init];
        user.name = [result objectForKey:@"name"];
        user.age = [result objectForKey:@"age"];
        user.signature = [result objectForKey:@"signature"];
        user.images = [result objectForKey:@"images"];
        user.avatar = [result objectForKey:@"avatar"];
        user.userId = [result objectForKey:@"userId"];
        [GlobalDataManager sharedInstance].user = user;
        [[EGOCache globalCache] setObject:user.userId forKey:@"userToken"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil];
    } onFailure:^(Error *error) {
        if(error.errorCode == 1102 || error.errorCode == 1103){
            [SVProgressHUD showErrorWithStatus:error.errorMsg];
        }else{
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
        }
    }];
    
}

- (void)doRegister{
    RegisterViewController* vc = [[RegisterViewController alloc] init];
    vc.title = @"注册";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)resignFocus{
    [_account resignFirstResponder];
    [_password resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    CGRect rc = self.view.bounds;
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, 100, _nameLabel.frame.size.width, _nameLabel.frame.size.height);
    _account.frame = CGRectMake(_account.frame.origin.x, 96, _account.frame.size.width, _account.frame.size.height);
    _passwordLabel.frame = CGRectMake(_passwordLabel.frame.origin.x, 150, _passwordLabel.frame.size.width, _passwordLabel.frame.size.height);
    _password.frame = CGRectMake(_password.frame.origin.x, 146, _password.frame.size.width, _password.frame.size.height);
    _selfLoginButton.frame = CGRectMake(_selfLoginButton.frame.origin.x, 200, _selfLoginButton.frame.size.width, _selfLoginButton.frame.size.height);

    
    _weiboLoginBtn.frame = CGRectMake(_weiboLoginBtn.frame.origin.x, rc.size.height - _weiboLoginBtn.frame.size.height - 10, _weiboLoginBtn.frame.size.width, _weiboLoginBtn.frame.size.height);
    _loginBtn.frame = CGRectMake(_loginBtn.frame.origin.x, _weiboLoginBtn.frame.origin.y - _loginBtn.frame.size.height - 10, _loginBtn.frame.size.width, _loginBtn.frame.size.height);
    _thirdPartyLabel.frame = CGRectMake(_thirdPartyLabel.frame.origin.x, _loginBtn.frame.origin.y + 18, _thirdPartyLabel.frame.size.width, _thirdPartyLabel.frame.size.height);

}

-(void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
