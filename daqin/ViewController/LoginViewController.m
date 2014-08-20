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
    [[EGOCache globalCache] setObject:@"123" forKey:@"userToken"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil];
    }else{
        [[QQHelper sharedInstance] doLogin];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loginBtn addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
