//
//  BXStateMessageCell.m
//  Baixing
//
//  Created by minjie on 14-5-16.
//
//

#import "StateMessageCell.h"
#import "StateMessage.h"

#define kTextFontSize           12.0f
#define kImageTopMargin         10.0f

@implementation StateMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier target:target];
    if (self) {
        
        self.stateLabel = [[UILabel alloc] init];
        self.stateLabel.backgroundColor = [UIColor colorWithRed:0xd9/255.0 green:0xd9/255.0 blue:0xd9/255.0 alpha:1];
        self.stateLabel.numberOfLines = 0;
        self.stateLabel.font = [UIFont systemFontOfSize:kTextFontSize];
        self.stateLabel.textColor = [UIColor whiteColor];
        self.stateLabel.layer.cornerRadius = 3.0f;
        self.stateLabel.clipsToBounds = YES;
        self.stateLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.stateLabel];
        
        [self initGestureRecognizerWithTarget:target];
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier target:nil];
    return self;
}

- (void)initGestureRecognizerWithTarget:(id)target
{
    
}

- (void)configCellWithMessage:(Message*)message
{
    [super configCellWithMessage:message];
    
    CGFloat yOffset = 0.0f;
    if (message.showTime) {
        yOffset = kTimeHeight;
    }
    
    StateMessage* stateMessage = (StateMessage*)message;
    NSString* text = stateMessage.stateMsg;
    
    UIFont* font = [UIFont systemFontOfSize:kTextFontSize];
    CGFloat maxTextWidth = kMaxMessageWidth;
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    CGFloat xOffset = (self.frame.size.width-size.width)/2;
    yOffset += kImageTopMargin;
    
    self.stateLabel.frame = CGRectMake(xOffset-5, yOffset, size.width+10, size.height+6);
    self.stateLabel.text = text;
}

+ (CGFloat)cellHeightWithMessage:(Message*)message
{
    StateMessage* stateMessage = (StateMessage*)message;
    NSString* text = stateMessage.stateMsg;
    
    UIFont* font = [UIFont systemFontOfSize:kTextFontSize];
    CGFloat maxTextWidth = kMaxMessageWidth;
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    size.height = ceil(size.height);
    
    return size.height+(kImageTopMargin)*2;
}

@end
