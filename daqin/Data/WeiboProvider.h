//
//  WeiboProvider.h
//  daqin
//
//  Created by BurizaDo on 8/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDefinition.h"

@interface WeiboProvider : NSObject
- (void)getUserSuccess:(ResponseObject)obj failure:(ResponseError)err;
+ (instancetype)sharedInstance;
@end
