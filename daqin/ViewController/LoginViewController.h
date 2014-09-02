//
//  LoginViewController.h
//  daqin
//
//  Created by BurizaDo on 7/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *weiboLoginBtn;
@property (nonatomic, strong) IBOutlet UIButton* loginBtn;
@property (nonatomic, assign) BOOL hasBack;
@end
