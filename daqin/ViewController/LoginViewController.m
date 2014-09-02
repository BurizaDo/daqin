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

@interface LoginViewController ()

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
//    self.title = @"登录";
    self.navigationItem.title = @"登录";
    [self.loginBtn addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.weiboLoginBtn addTarget:self action:@selector(weiboLogin) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSucceed) name:@"loginSucceed" object:nil];
    if(_hasBack){
        self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(handleBack)];
    }
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
