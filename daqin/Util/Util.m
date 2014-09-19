//
//  BXUtil.m
//  Baixing
//
//  Created by XuMengyi on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "NSData+JSON.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"

//#define APP_ID @"591540113"
#define APP_ID @"913940726"

@implementation Util


+ (CGSize)scaleSize:(CGSize)size maxSize:(CGSize)maxSize
{
    if (size.width > maxSize.width && size.height > maxSize.height) {
        CGFloat widthScale = size.width/maxSize.width;
        CGFloat heightScale = size.height/maxSize.height;
        if (widthScale>heightScale) {
            size.width = maxSize.width;
            size.height = size.height/widthScale;
        }
        else{
            size.height = maxSize.height;
            size.width = size.width/heightScale;
        }
    }
    else if(size.width > maxSize.width)
    {
        CGFloat widthScale = size.width/maxSize.width;
        size.width = maxSize.width;
        size.height = size.height/widthScale;
    }
    else if(size.height > maxSize.height)
    {
        CGFloat heightScale = size.height/maxSize.height;
        size.height = maxSize.height;
        size.width = size.width/heightScale;
    }
    
    return size;
}

+ (NSString *) GUID
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidStringRef);
    return uuid;
}

+ (void)doUpdate{
    NSString *reviewURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", APP_ID];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];

}

+ (void)checkUpdate:(id<UIAlertViewDelegate>)delegate{
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", APP_ID];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [SVProgressHUD showWithStatus:@"检查中……" maskType:SVProgressHUDMaskTypeBlack];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSError *err = nil;
        if(err) {
        } else {
            NSDictionary *dict = [responseObject objectFromJSONData];
            if (dict && [dict objectForKey:@"results"]) {
                NSArray *result = [dict objectForKey:@"results"];
                if (result && result.count > 0) {
                    NSString *version = result[0][@"version"];
                    NSString* curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"0.1";
                    if ([version compare:curVersion options:NSNumericSearch] == NSOrderedDescending) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *msg = [NSString stringWithFormat:@"最新的版本是%@，现在就去更新吗?", version];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新提示"
                                                                            message:msg
                                                                           delegate:delegate
                                                                  cancelButtonTitle:@"取消"
                                                                  otherButtonTitles:@"更新", nil];
                            [alert show];
                        });
                        return;
                    }
                }else{
                    if(delegate){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新提示"
                                                                        message:@"已经是最新版本了"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"确认"
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
    [operation start];
}

@end
