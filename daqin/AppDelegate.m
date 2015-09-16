//
//  AppDelegate.m
//  daqin
//
//  Created by BurizaDo on 7/22/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "HttpClient.h"
#define HOST @"http://localhost:8888/iparty_cloud/index.php"
//#define HOST @"http://192.168.1.149:8888/Rome/"
//#define HOST @"http://localhost:8888/Rome/"
#import "ChatSession.h"
#import "EGOCache.h"
#import "UserProvider.h"
#import "ChatUser.h"
#import "GlobalDataManager.h"
#import "MobClick.h"
#import "SVProgressHUD.h"
#import "WeiboSDK.h"
#import "LoginManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [HttpClient configWith:HOST key:@"" secret:@""];
    [[ChatSession sharedInstance] setup];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert
      | UIRemoteNotificationTypeBadge
      | UIRemoteNotificationTypeSound)];


    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:0.95]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:1]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSString* userId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
    if(userId){
        [UserProvider getUsers:userId onSuccess:^(NSArray *users) {
            if([users count] == 0) return;
            User* user = users[0];
            [GlobalDataManager sharedInstance].user = user;
            ChatUser* selfUser = [[ChatUser alloc] initWithPeerId:user.userId displayName:user.name iconUrl:user.avatar];
            [[ChatSession sharedInstance] enableChat:selfUser];
        } onFailure:^(Error *error) {
        }];
    }
    
//    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"653706130"];
    [MobClick startWithAppkey:@"53faac1cfd98c506e50003af" reportPolicy:BATCH channelId:@"AppStore"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[LoginManager sharedInstance] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [[LoginManager sharedInstance] handleOpenURL:url];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
//    [SVProgressHUD showErrorWithStatus:@"Register for remote fail"];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)webDeviceToken
{
//    [SVProgressHUD showErrorWithStatus:@"in didRegister"];
    NSString *pushToken = [[webDeviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(pushToken == nil) return; // from umeng crash report, deviceToken here may be nil. So just ignore.
    
    [[ChatSession sharedInstance] setDeviceToken:webDeviceToken];
}


@end
