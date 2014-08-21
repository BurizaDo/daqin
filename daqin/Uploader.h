//
//  Uploader.h
//  daqin
//
//  Created by BurizaDo on 8/4/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Uploader : NSObject
+ (void)uploadImage:(UIImage*)image
          onSuccess:(void(^)(NSString*))success
          onFailure:(void(^)(NSString*))failure
         onProgress:(void(^)(CGFloat, long long))progress;

+ (void)uploadFile:(NSString*)filePath
          onSuccess:(void(^)(NSString*))success
          onFailure:(void(^)(NSString*))failure
         onProgress:(void(^)(CGFloat, long long))progress;

@end
