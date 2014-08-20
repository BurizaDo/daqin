//
//  ViewUtil.m
//  daqin
//
//  Created by BurizaDo on 8/18/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ViewUtil.h"

@implementation ViewUtil

+ (UIBarButtonItem*) createBackItem:(UIViewController*)vc action:(SEL)selection{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:vc action:selection forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    item.style = UIBarButtonItemStylePlain;
    return item;
}

@end
