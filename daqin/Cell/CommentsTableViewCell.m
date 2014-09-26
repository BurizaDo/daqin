//
//  CommentsTableViewCell.m
//  daqin
//
//  Created by BurizaDo on 9/23/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "CommentsTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface CommentsTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation CommentsTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)adaptWithComment:(Comment*)comment{
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.user.avatar]];
    _avatarImageView.layer.cornerRadius = _avatarImageView.frame.size.width / 2;
    _avatarImageView.layer.masksToBounds = YES;
    _nameLabel.text = comment.user.name;
    
    NSString* text = comment.message;
    if(comment.replyUser){
        NSString* reply = @"回复 ";
        text = [[reply stringByAppendingString:comment.replyUser.name] stringByAppendingString:@"："];
        text = [text stringByAppendingString:comment.message];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString* time = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:comment.timestamp]];
    _timeLabel.text = time;

    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    _messageLabel.text = text;
    _messageLabel.numberOfLines = 10;

    CGSize maximumLabelSize = CGSizeMake(_messageLabel.frame.size.width,999);
    CGSize expectedLabelSize = [text sizeWithFont:_messageLabel.font
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:_messageLabel.lineBreakMode];
    
    _messageLabel.frame = CGRectMake(_messageLabel.frame.origin.x, _messageLabel.frame.origin.y, _messageLabel.frame.size.width, expectedLabelSize.height);
    _timeLabel.frame = CGRectMake(_timeLabel.frame.origin.x, _messageLabel.frame.origin.y + _messageLabel.frame.size.height + 5, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    self.frame = CGRectMake(0, 0, self.bounds.size.width, _timeLabel.frame.origin.y + _timeLabel.frame.size.height + 10);
}

@end
