//
//  SettingCell.m
//  daqin
//
//  Created by BurizaDo on 8/27/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell

- (void)awakeFromNib
{
    self.name.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1];
}

- (void)setRightArrowHidden:(BOOL)rightArrowHidden
{
    _rightArrowHidden = rightArrowHidden;
    if (_rightArrowHidden) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}


@end
