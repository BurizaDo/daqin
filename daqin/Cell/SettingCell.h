//
//  SettingCell.h
//  daqin
//
//  Created by BurizaDo on 8/27/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UISwitch *switchCtrl;
@property (nonatomic, assign) BOOL rightArrowHidden;
@end
