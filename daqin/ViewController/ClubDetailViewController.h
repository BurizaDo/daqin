//
//  RouteDetailViewController.h
//  daqin
//
//  Created by BurizaDo on 7/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"

@interface ClubDetailViewController : UIViewController
@property (nonatomic, strong) Club* club;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* address;
@property (nonatomic, weak) IBOutlet UILabel* meta;
@property (nonatomic, weak) IBOutlet UIScrollView* imagesView;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@end
