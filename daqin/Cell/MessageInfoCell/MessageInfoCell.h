//
//  BXMessageInfoCell.h
//  Baixing
//
//  Created by neoman on 5/20/14.
//
//

#import <Foundation/Foundation.h>

@class MessageInfo;

@interface MessageInfoCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel*           titleLabel;
@property (nonatomic, weak) IBOutlet UILabel*           subTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView*       iconView;
@property (nonatomic, weak) IBOutlet UILabel*           dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *      badgeImageView;
- (void)configureCellWithMessageInfo:(MessageInfo *)messageInfo;

@end
