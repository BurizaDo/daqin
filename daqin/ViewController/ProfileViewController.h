//
//  ProfileViewController.h
//  daqin
//
//  Created by BurizaDo on 8/18/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileViewController : UITableViewController
@property (nonatomic, strong) User* user;
@end
