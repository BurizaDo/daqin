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
#import "MessageProvider.h"
#import "GlobalDataManager.h"
#import "MessageInfo.h"

@interface RootViewController () <UITabBarControllerDelegate>

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

- (UITabBarItem*) createTabBarItemImage:(NSString*)imageName selected:(NSString*)selName{
    UITabBarItem* item = [[UITabBarItem alloc]init];
    item.title = nil;
    [item setFinishedSelectedImage:[UIImage imageNamed:selName] withFinishedUnselectedImage:[UIImage imageNamed:imageName]];
    item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    return item;
}

- (void)loginOut{
    NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    UINavigationController* post = [self generateLoginNavControllerImage:@"03" selected:@"select_03"];
//    UINavigationController* my = [self generateLoginNavControllerImage:@"04" selected:@"select_04"];
    [GlobalDataManager sharedInstance].user = nil;
    [controllers replaceObjectAtIndex:2 withObject:post];
//    [controllers replaceObjectAtIndex:3 withObject:my];
    self.viewControllers = controllers;
}

- (void)switchViewController{
    PostViewController* postVC = [[PostViewController alloc] init];
    UINavigationController* postNC = [[UINavigationController alloc] initWithRootViewController:postVC];
    postNC.tabBarItem = [self createTabBarItemImage:@"03" selected:@"select_03"];
    
    NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    [controllers replaceObjectAtIndex:2 withObject:postNC];
    self.viewControllers = controllers;
}

- (void)registerSucceed{
    [self switchViewController];
    self.selectedIndex = 3;
}

- (void)loginSucceed{
    [self switchViewController];
}

- (UINavigationController*)generateLoginNavControllerImage:(NSString*)imageName selected:(NSString*)sel{
    LoginViewController* loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController* newNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    newNC.tabBarItem = [self createTabBarItemImage:imageName selected:sel];
    return newNC;
    
}

- (void)messageChanged{
    MessageInfo* msg = [MessageProvider queryMessageInfoSummaryUserChatId:[GlobalDataManager sharedInstance].user.userId];
    if(msg.badgeCount > 0){
        NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.viewControllers];
        UINavigationController* msg = controllers[1];
        [msg.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"select_02"] withFinishedUnselectedImage:[UIImage imageNamed:@"chat_new"]];
    }else{
        NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.viewControllers];
        UINavigationController* msg = controllers[1];
        [msg.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"select_02"] withFinishedUnselectedImage:[UIImage imageNamed:@"02"]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    // Do any additional setup after loading the view.
    NSString* token = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
    NSMutableArray* controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    if(!token){
        UINavigationController* post = [self generateLoginNavControllerImage:@"03" selected:@"select_03"];
//        UINavigationController* my = [self generateLoginNavControllerImage:@"04" selected:@"select_04"];
        
        [controllers replaceObjectAtIndex:2 withObject:post];
//        [controllers replaceObjectAtIndex:3 withObject:my];
        self.viewControllers = controllers;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSucceed) name:@"registerSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceed) name:@"loginSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut) name:@"didlogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSucceed) name:kPostSucceed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageChanged) name:kNotifcationMessageChange object:nil];

    
    UINavigationController* list = controllers[0];
    list.tabBarItem = [self createTabBarItemImage:@"01" selected:@"select_01"];
    list = controllers[1];
    list.tabBarItem = [self createTabBarItemImage:@"02" selected:@"select_02"];
    list = controllers[2];
    list.tabBarItem = [self createTabBarItemImage:@"03" selected:@"select_03"];
    list = controllers[3];
    list.tabBarItem = [self createTabBarItemImage:@"04" selected:@"select_04"];

    
    self.tabBar.barTintColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1];
    self.tabBar.translucent = NO;
    self.tabBar.opaque = YES;
    
}

-(void)postSucceed{
    self.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
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
