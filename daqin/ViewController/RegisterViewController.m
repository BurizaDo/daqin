//
//  RegisterViewController.m
//  daqin
//
//  Created by BurizaDo on 9/15/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "RegisterViewController.h"
#import "ViewUtil.h"
#import "SVProgressHUD.h"
#import "UserProvider.h"
#import "GlobalDataManager.h"
#import "EGOCache.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirm;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(back)];
    UIGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFocus)];
    [self.view addGestureRecognizer:gesture];
    
}

- (void)resignFocus{
    [_account resignFirstResponder];
    [_password resignFirstResponder];
    [_confirm resignFirstResponder];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, 100, _nameLabel.frame.size.width, _nameLabel.frame.size.height);
    _account.frame = CGRectMake(_account.frame.origin.x, 96, _account.frame.size.width, _account.frame.size.height);
    _passwordLabel.frame = CGRectMake(_passwordLabel.frame.origin.x, 150, _passwordLabel.frame.size.width, _passwordLabel.frame.size.height);
    _password.frame = CGRectMake(_password.frame.origin.x, 146, _password.frame.size.width, _password.frame.size.height);
    _confirmLabel.frame = CGRectMake(_confirmLabel.frame.origin.x, 200, _confirmLabel.frame.size.width, _confirmLabel.frame.size.height);
    _confirm.frame = CGRectMake(_confirm.frame.origin.x, 196, _confirm.frame.size.width, _confirm.frame.size.height);
    _registerBtn.frame = CGRectMake(_registerBtn.frame.origin.x, 250, _registerBtn.frame.size.width, _registerBtn.frame.size.height);
    [_registerBtn addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
}

-(BOOL)check{
    NSString* str = [_account.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(str.length == 0){
        [SVProgressHUD showErrorWithStatus:@"请填写用户名"];
        return FALSE;
    }
    NSString* pwd = [_password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* pwdConfirm = [_confirm.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(![pwd isEqualToString:pwdConfirm]){
        [SVProgressHUD showErrorWithStatus:@"密码输入不一致"];
        return FALSE;
    }
    return TRUE;
}

-(void)doRegister{
    if(![self check]) return;
    [UserProvider registerUser:_account.text password:_password.text onSuccess:^(id object) {
        User* user = [[User alloc]init];
        user.userId = object;
        user.name = _account.text;
        [GlobalDataManager sharedInstance].user = user;
        [[EGOCache globalCache] setObject:object forKey:@"userToken"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"registerSucceed" object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } onFailure:^(Error *error) {
        if(error.errorCode == 1101){
            [SVProgressHUD showErrorWithStatus:error.errorMsg];
        }else{
            [SVProgressHUD showErrorWithStatus:@"注册失败，请稍后重试"];
        }
    }];
}

@end
