//
//  BXUtil.h
//  Baixing
//
//  Created by XuMengyi on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIAlertView.h>
#define INT_VAL(x)             [BXUtil longLongValue:(x)]
#define STR_VAL(x)             [BXUtil stringValue:(x)]
#define DOUBLE_VAL(x)          [BXUtil doubleValue:(x)]

#define INT2S(n)               [[NSString alloc] initWithFormat:@"%d", n]
#define LONG2S(l)              [[NSString alloc] initWithFormat:@"%ld", l]
#define FLOAT2S(f)             [[NSString alloc] initWithFormat:@"%f", f]
#define BOOL2S(b)              INT2S(b)


@interface Util : NSObject

+ (CGSize)scaleSize:(CGSize)size maxSize:(CGSize)maxSize;
+ (NSString *) GUID;

+ (void)checkUpdate:(id<UIAlertViewDelegate>)delegate;

+ (void)doUpdate;
@end
