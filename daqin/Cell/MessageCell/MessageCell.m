//
//  BXMessageCell.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "MessageCell.h"
#import "Message.h"
#import "TextMessageCell.h"
#import "ImageMessageCell.h"
#import "StateMessageCell.h"
#import "VoiceMessageCell.h"
#import "UIImageView+WebCache.h"
#import "EventDefinition.h"

#define kTimeFontSize 12.0f

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.avatarView];
        
        self.tapMaskView = [[UIView alloc] init];
        [self.contentView addSubview:self.tapMaskView];
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:self.loadingView];
        
        self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.retryButton setBackgroundImage:[UIImage imageNamed:@"Myads_Body_Icon_Forbidden"] forState:UIControlStateNormal];
        [self.retryButton addTarget:self action:@selector(resendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.retryButton];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.backgroundColor = [UIColor colorWithRed:0xd9/255.0 green:0xd9/255.0 blue:0xd9/255.0 alpha:1];
        self.timeLabel.font = [UIFont systemFontOfSize:kTimeFontSize];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.layer.cornerRadius = 3.0f;
        self.timeLabel.clipsToBounds = YES;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.timeLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier target:nil];
    return self;
}

+ (id)createMessageCellMessage:(Message*)message reuseIdentifier:(NSString *)reuseIdentifier target:(id)target
{
    MessageCell* cell;
    if (message.type == MessageTypeText) {
        cell = [[TextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier target:target];
    }
    else if (message.type == MessageTypeImage) {
        cell = [[ImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier target:target];
    }
    else if (message.type == MessageTypeState) {
        cell = [[StateMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier target:target];
    } else if(message.type == MessageTypeVoice){
        cell = [[VoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier target:target];
    }
    
    return cell;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

static NSDateFormatter *dateFormatter;
- (void)configCellWithMessage:(Message*)message
{
    CGFloat yOffset = 0.0f;
    if (message.showTime) {
        yOffset = kTimeHeight;
    }
    
    if (message.from == MessageFromMine) {
        self.messageDirection = MessageDirectionRight;
    }
    else if(message.from == MessageFromOther){
        self.messageDirection = MessageDirectionLeft;
    }
    
    if (message.type == MessageTypeState) {
        self.messageDirection = MessageDirectionCenter;
    }
    
    if (self.messageDirection == MessageDirectionLeft || self.messageDirection == MessageDirectionRight) {
        self.avatarView.hidden = NO;
        if (self.messageDirection == MessageDirectionLeft) {
            self.avatarView.frame = CGRectMake(kAvatarMargin, yOffset+kAvatarMargin, kAvatarWidth, kAvatarWidth);
            
        }
        else{
            CGFloat fullWidth = self.frame.size.width;
            self.avatarView.frame = CGRectMake(fullWidth-kAvatarMargin-kAvatarWidth, yOffset+kAvatarMargin, kAvatarWidth, kAvatarWidth);
        }
        self.avatarView.layer.cornerRadius = _avatarView.bounds.size.height/2;
        _avatarView.layer.masksToBounds = YES;
        [self.avatarView setImageWithURL:[NSURL URLWithString:message.avatarUrl] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
        
        if (message.state == MessageStateSending) {
            [self.loadingView startAnimating];
            self.loadingView.hidden = NO;
            self.retryButton.hidden = YES;
        }
        else if (message.state == MessageStateSendOK){
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
            self.retryButton.hidden = YES;
        }
        else{
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
            self.retryButton.hidden = NO;
        }
    }
    else{
        self.avatarView.hidden = YES;
    }
    
    if (message.showTime) {
        dateFormatter = [[NSDateFormatter alloc] init];
        
        int timeInterval = [[NSDate date] timeIntervalSince1970];
        double todayInterval = timeInterval-timeInterval%(3600*24);
        double yesterdayInterval = todayInterval-(3600*24);
        if ([message.time timeIntervalSince1970]>todayInterval){
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        else if([message.time timeIntervalSince1970]>yesterdayInterval){
            [dateFormatter setDateFormat:@"昨天 HH:mm"];
        }
        else{
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        }        
        
        NSString *currentDateStr = [dateFormatter stringFromDate:message.time];
        
        UIFont* font = [UIFont systemFontOfSize:kTimeFontSize];
        CGFloat maxTextWidth = kMaxMessageWidth;
        CGSize size = [currentDateStr sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        
        CGFloat xOffset = (self.frame.size.width-size.width)/2;
        CGFloat yOffset = 7.0f;
        
        self.timeLabel.frame = CGRectMake(xOffset-5, yOffset, size.width+10, size.height+6);
        self.timeLabel.text = currentDateStr;
    }
    self.timeLabel.hidden = !message.showTime;
    
    self.tapGestureRecognizer.view.tag = self.indexPath.row;
}

+ (CGFloat)cellHeightWithMessage:(Message*)message
{
    CGFloat height = 0.0;
    
    if(message.type == MessageTypeText)
    {
        height = [TextMessageCell cellHeightWithMessage:message];
    }
    else if(message.type == MessageTypeImage)
    {
        height = [ImageMessageCell cellHeightWithMessage:message];
    }
    else if(message.type == MessageTypeState)
    {
        height = [StateMessageCell cellHeightWithMessage:message];
    }
    
    if (height < 60) {
        height = 60;
    }
    
    if (message.showTime) {
        height += kTimeHeight;
    }

    return height;
}

- (void)initGestureRecognizerWithTarget:(id)target
{
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyed:));
}

- (void)resendMessage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageSentAgain object:self.indexPath userInfo:nil];
}
@end
