//
//  CommentsTableViewCell.h
//  daqin
//
//  Created by BurizaDo on 9/23/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface CommentsTableViewCell : UITableViewCell
- (void)adaptWithComment:(Comment*)comment;
@end
