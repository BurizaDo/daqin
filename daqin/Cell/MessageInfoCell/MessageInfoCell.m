//
//  BXMessageInfoCell.m
//  Baixing
//
//  Created by neoman on 5/20/14.
//
//

#import "MessageInfoCell.h"

#import "MessageInfo.h"
#import "JSBadgeView.h"
#import <UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"

@interface MessageInfoCell()

@property (nonatomic, strong) JSBadgeView *badgeView;


@end

@implementation MessageInfoCell

- (void)configureCellWithMessageInfo:(MessageInfo *)messageInfo
{
    self.titleLabel.text = messageInfo.name;
    self.subTitleLabel.text = messageInfo.content;
    self.dateLabel.text = [messageInfo.timeStamp timeAgo];
    
    [self.iconView setImageWithURL:[NSURL URLWithString:messageInfo.iconUrl]
                  placeholderImage:[UIImage imageNamed:@"Public_Body_Icon_Loadpic.png"]];
    
    if (messageInfo.badgeCount > 0) {
        self.badgeView.hidden = NO;
        self.badgeView.badgeText = [@(messageInfo.badgeCount) description];
    } else {
        self.badgeView.hidden = YES;
    }
}

- (JSBadgeView *)badgeView
{
    if (_badgeView == nil) {
        _badgeView = [[JSBadgeView alloc] initWithParentView:self.iconView alignment:JSBadgeViewAlignmentTopRight];
        _badgeView.badgeBackgroundColor = [UIColor colorWithRed:0xfe/255.0 green:0x6c/255.0 blue:0 alpha:1.0];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:13.0f];
        _badgeView.hidden = YES;
    }
    
    return _badgeView;
}

@end
