//
//  BXTextMessageCell.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "TextMessageCell.h"
#import "TextMessage.h"

#define kArrowWidth             10.0f
#define kTextLeftSideMargin     10.0f
#define kTextRightSideMargin    15.0f
#define kTextImageYMargin       10.0f
#define kImageTopMargin         10.0f
#define kTextFontSize           16.0f

@implementation TextMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier target:target];
    if (self) {
        
        self.bgImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:self.bgImageView];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont systemFontOfSize:kTextFontSize];
        [self.contentView addSubview:self.titleLabel];
        
        
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
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(handleDoubleHitGesture:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.tapMaskView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:@selector(handleLongPressGesture:)];
    [self.tapMaskView addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)configCellWithMessage:(Message*)message
{
    [super configCellWithMessage:message];
    
    CGFloat yOffset = 0.0f;
    if (message.showTime) {
        yOffset = kTimeHeight;
    }
    
    TextMessage* textMessage = (TextMessage*)message;
    NSString* text = textMessage.text;
    
    UIImage* image;
    if (self.messageDirection == MessageDirectionLeft){
        image = [UIImage imageNamed:@"message_bg_receiving"];
    }
    else{
        image = [UIImage imageNamed:@"message_bg_sending"];
    }
    self.bgImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)];
    
    UIFont* font = [UIFont systemFontOfSize:kTextFontSize];
    CGFloat maxTextWidth = kMaxMessageWidth-kArrowWidth-kTextLeftSideMargin-kTextRightSideMargin;
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    size.width = ceil(size.width);
    size.height = ceil(size.height);

    CGRect loadingRect;
    
    if (self.messageDirection == MessageDirectionLeft) {
        self.bgImageView.frame = CGRectMake(kAvatarAll, yOffset+kImageTopMargin, kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+size.width, size.height+kTextImageYMargin*2);
        self.titleLabel.frame = CGRectMake(kAvatarAll+kArrowWidth+kTextLeftSideMargin, yOffset+kTextImageYMargin+kImageTopMargin, size.width, size.height);
        
        loadingRect = CGRectMake(self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width, self.bgImageView.frame.origin.y, 16, 16);
    }
    else{
        
        CGFloat fullWidth = self.frame.size.width;
        CGFloat xOffset = fullWidth-(kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+size.width)-kAvatarAll;
        self.bgImageView.frame = CGRectMake(xOffset, yOffset+kImageTopMargin, kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+size.width, size.height+kTextImageYMargin*2);
        
        xOffset = fullWidth-(size.width)-kAvatarAll-kArrowWidth-kTextLeftSideMargin;
        self.titleLabel.frame = CGRectMake(xOffset, yOffset+kTextImageYMargin+kImageTopMargin, size.width, size.height);
        
        loadingRect = CGRectMake(self.bgImageView.frame.origin.x-16, self.bgImageView.frame.origin.y, 16, 16);
    }
    
    self.tapMaskView.frame = self.bgImageView.frame;
    [self.contentView bringSubviewToFront:self.tapMaskView];
    
    self.loadingView.frame = loadingRect;
    self.retryButton.frame = loadingRect;

    self.titleLabel.text = text;
    
    
}

+ (CGFloat)cellHeightWithMessage:(Message*)message
{
    TextMessage* textMessage = (TextMessage*)message;
    NSString* text = textMessage.text;
    
    UIFont* font = [UIFont systemFontOfSize:kTextFontSize];
    CGFloat maxTextWidth = kMaxMessageWidth-kArrowWidth-kTextLeftSideMargin-kTextRightSideMargin;
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    size.height = ceil(size.height);
    
    return size.height+(kTextImageYMargin+kImageTopMargin)*2;
}

@end
