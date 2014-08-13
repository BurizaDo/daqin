//
//  GlobalDataManager.m
//  daqin
//
//  Created by BurizaDo on 8/11/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "GlobalDataManager.h"
@implementation GlobalDataManager

static GlobalDataManager *_sharedInstance = nil;

+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}
@end
