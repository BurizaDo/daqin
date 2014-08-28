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

- (void)loginClicked{
    if (TARGET_IPHONE_SIMULATOR){
//    [[EGOCache globalCache] setObject:@"123" forKey:@"userToken"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil];
        WBAuthorizeRequest* request = [WBAuthorizeRequest request];
        request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }else{
        [[QQHelper sharedInstance] doLogin];
    }
}

- (void)weiboLogin{
    if (TARGET_IPHONE_SIMULATOR){
        //    [[EGOCache globalCache] setObject:@"123" forKey:@"userToken"];
        //    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil];
        WBAuthorizeRequest* request = [WBAuthorizeRequest request];
        request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }else{
        WBAuthorizeRequest* request = [WBAuthorizeRequest request];
        request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loginBtn addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.weiboLoginBtn addTarget:self action:@selector(weiboLogin) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
