//
//  Uploader.m
//  daqin
//
//  Created by BurizaDo on 8/4/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "Uploader.h"
#import "UpYun.h"

#define BUCKET @"daqin"
#define SECRET_KEY @"yAPHkMZSn5jTo6EYvfVNDVNC/DU="
#define EXPIRE 600
#define UPLOADURL @"http://daqin.b0.upaiyun.com"

@implementation Uploader
+ (void)uploadImage:(UIImage*)image
          onSuccess:(void(^)(NSString*))success
          onFailure:(void(^)(NSString*))failure
         onProgress:(void(^)(CGFloat, long long))progress{
    UpYun* yun = [[UpYun alloc] init];
    yun.bucket = BUCKET;
    yun.passcode = SECRET_KEY;
    yun.expiresIn = EXPIRE;
    NSDate* date = [NSDate date];
    int secs = (int)[date timeIntervalSince1970];
    NSString* saveKey = [[[NSString alloc] init]stringByAppendingFormat:@"/%d", secs];
    
    yun.successBlocker = ^(id result){
        NSDictionary* dic = result;
        NSString* url = UPLOADURL;
        success([url stringByAppendingString:[dic objectForKey:@"url"]]);
    };
    
    yun.failBlocker = ^(NSError * error){
        failure([error.userInfo objectForKey:@"message"]);
    };
    
    yun.progressBlocker = ^(CGFloat percent, long long sent){
        if(progress){
            progress(percent, sent);
        }
    };
    
    [yun uploadImage:image savekey:saveKey];
}
@end
