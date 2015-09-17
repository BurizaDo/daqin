//
//  ClubCell.h
//  daqin
//
//  Created by BurizaDo on 9/17/15.
//  Copyright (c) 2015 BurizaDo. All rights reserved.
//

#ifndef daqin_ClubCell_h
#define daqin_ClubCell_h
@interface ClubCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* address;

@end

#endif
