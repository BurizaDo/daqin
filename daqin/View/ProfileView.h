//
//  ProfileView.h
//  daqin
//
//  Created by BurizaDo on 8/27/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileView : UIView
@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (weak, nonatomic) IBOutlet UIImageView *mask;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* age;
@property (nonatomic, weak) IBOutlet UILabel* signature;

@end
