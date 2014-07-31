//
//  RouteDetailViewController.h
//  daqin
//
//  Created by BurizaDo on 7/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface RouteDetailViewController : UIViewController
@property (nonatomic, strong) Route* route;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* signature;
@property (nonatomic, weak) IBOutlet UILabel* destination;
@property (nonatomic, weak) IBOutlet UILabel* schedule;
@property (nonatomic, weak) IBOutlet UILabel* description;
@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UIScrollView* imagesView;
@property (nonatomic, weak) IBOutlet UIButton* chatButton;
@property (nonatomic, weak) IBOutlet UILabel* age;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@end
