//
//  RootViewController.m
//  daqin
//
//  Created by BurizaDo on 7/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"
#import "EGOCache.h"
#import "PostViewController.h"
#import "EventDefinition.h"
#import "ProfileViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loginSucceed{
    PostViewController* postVC = [[PostViewController alloc] init];
    UINavigationController* postNC = [[UINavigationController alloc] initWithRootViewController:postVC];
    postNC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"发布" image:[UIImage imageNamed:@"first"] tag:0];

    ProfileViewController* myVC = [[ProfileViewController alloc] init];
    UINavigationController* myNC = [[UINavigationController alloc] initWithRootViewController:myVC];
    myNC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"我的" image:[UIImage imageNamed:@"first"] tag:0];
    myNC.title = @"个人中心";
    myNC.navigationBar.translucent = NO;

    
    NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    [controllers replaceObjectAtIndex:1 withObject:myNC];
    [controllers replaceObjectAtIndex:2 withObject:postNC];
    self.viewControllers = controllers;
}

- (UINavigationController*)generateLoginNavController:(NSString*)tabItemText image:(NSString*)imageName{
    LoginViewController* loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController* newNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    newNC.tabBarItem = [[UITabBarItem alloc]initWithTitle:tabItemText image:[UIImage imageNamed:imageName] tag:0];
    return newNC;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString* token = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
    if(!token){
        UINavigationController* post = [self generateLoginNavController:@"发布" image:@"first"];
        UINavigationController* my = [self generateLoginNavController:@"我的" image:@"first"];
        
        NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.viewControllers];
        [controllers replaceObjectAtIndex:2 withObject:post];
        [controllers replaceObjectAtIndex:1 withObject:my];
        self.viewControllers = controllers;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceed) name:@"loginSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSucceed) name:kPostSucceed object:nil];
    
}

-(void)postSucceed{
    self.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
