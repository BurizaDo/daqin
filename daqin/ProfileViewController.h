//
//  ProfileViewController.h
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* age;
@property (nonatomic, weak) IBOutlet UILabel* signature;
@property (nonatomic, weak) IBOutlet UIScrollView* imagesView;
@end
