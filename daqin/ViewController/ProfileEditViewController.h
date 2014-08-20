//
//  ProfileViewController.h
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileEditViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UITextField* name;
@property (nonatomic, weak) IBOutlet UITextField* age;
@property (nonatomic, weak) IBOutlet UITextField* signature;
@property (nonatomic, weak) IBOutlet UIScrollView* imagesView;
@property (nonatomic, weak) IBOutlet UISegmentedControl* genderSeg;
@property (nonatomic, strong) User* user;
@end

