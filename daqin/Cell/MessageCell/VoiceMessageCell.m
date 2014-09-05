//
//  BXVoiceMessageCell.m
//  Baixing
//
//  Created by XuMengyi on 14-6-20.
//
//

#import "VoiceMessageCell.h"
#import "VoiceMessage.h"

@implementation VoiceMessageCell
#define kArrowWidth             10.0f
#define kTextLeftSideMargin     10.0f
#define kTextRightSideMargin    15.0f
#define kTextImageYMargin       10.0f
#define kImageTopMargin         10.0f
#define kTextFontSize           12.0f
#define kVoiceLabelSize           80.0f
#define kTextAvatarMargin       5.0f

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier target:target];
    if (self) {
        
        self.bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.bgImageView];
        self.voiceImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.voiceImageView];
        self.durationLabel = [[UILabel alloc] init];
        self.durationLabel.backgroundColor = [UIColor clearColor];
        self.durationLabel.numberOfLines = 0;
        self.durationLabel.textColor = [UIColor colorWithRed:0x4e/255.0 green:0x64/255.0 blue:0x79/255.0 alpha:1];
        self.durationLabel.font = [UIFont systemFontOfSize:kTextFontSize];
        [self.contentView addSubview:self.durationLabel];
        
        
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
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(handleHitGesture:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.bgImageView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)configCellWithMessage:(Message*)message
{
    [super configCellWithMessage:message];
    
    CGFloat yOffset = 0.0f;
    if (message.showTime) {
        yOffset = kTimeHeight;
    }
    VoiceMessage* textMessage = (VoiceMessage*)message;
    NSString* text = [NSString stringWithFormat:@"%d\"", textMessage.duration];
    
    UIImage* image;
    UIImage* imageSel;
    if (self.messageDirection == MessageDirectionLeft){
        image = [UIImage imageNamed:@"message_bg_receiving"];
        imageSel = [UIImage imageNamed:@"chatto_bg_pressed"];
    } 
    else{
        image = [UIImage imageNamed:@"message_bg_sending"];
        imageSel = [UIImage imageNamed:@"chatfrom_bg_pressed"];
    }
    [self.bgImageView setBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)] forState:UIControlStateNormal ];
    [self.bgImageView setBackgroundImage:[imageSel resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)] forState:UIControlStateSelected|UIControlStateHighlighted ];


    UIFont* font = [UIFont systemFontOfSize:kTextFontSize];
    CGFloat maxTextWidth = kMaxMessageWidth-kArrowWidth-kTextLeftSideMargin-kTextRightSideMargin;
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    float actualVoiceLabelWidth = textMessage.duration <= 3 ? kVoiceLabelSize / 2 : kVoiceLabelSize;
    
    CGRect loadingRect;
    
    if (self.messageDirection == MessageDirectionLeft) {
        self.bgImageView.frame = CGRectMake(kAvatarAll + kTextAvatarMargin, yOffset+kImageTopMargin, kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+actualVoiceLabelWidth, size.height+kTextImageYMargin*2);
        
        UIImage* voice = [UIImage imageNamed:@"voice_others_0032.png"];
        self.voiceImageView.image = voice;
        CGFloat voiceHeight = self.bgImageView.frame.size.height - 20;
        CGFloat voiceWidth = voice.size.width / voice.size.height * voiceHeight;
        
        self.voiceImageView.frame = CGRectMake(self.bgImageView.frame.origin.x + kTextLeftSideMargin * 2,
                                               self.bgImageView.frame.origin.y + (self.bgImageView.frame.size.height - voiceHeight) / 2,
                                               voiceWidth, voiceHeight);
        
        self.durationLabel.frame = CGRectMake(self.bgImageView.frame.size.width + self.bgImageView.frame.origin.x + kTextLeftSideMargin / 2, yOffset+kTextImageYMargin+kImageTopMargin, size.width, size.height);
        
        loadingRect = CGRectMake(self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width, self.bgImageView.frame.origin.y, 16, 16);
    }
    else{
        CGFloat fullWidth = self.frame.size.width;
        CGFloat xOffset = fullWidth-(kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+actualVoiceLabelWidth)-kAvatarAll - kTextAvatarMargin;
        self.bgImageView.frame = CGRectMake(xOffset, yOffset+kImageTopMargin, kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+actualVoiceLabelWidth, size.height+kTextImageYMargin*2);
        
        UIImage* voice = [UIImage imageNamed:@"voice_my_0032.png"];
        self.voiceImageView.image = voice;
        CGFloat voiceHeight = self.bgImageView.frame.size.height - 20;
        CGFloat voiceWidth = voice.size.width / voice.size.height * voiceHeight;
        self.voiceImageView.frame = CGRectMake(self.bgImageView.frame.origin.x + self.bgImageView.frame.size.width - voiceWidth - kTextLeftSideMargin * 2,
                                               self.bgImageView.frame.origin.y + (self.bgImageView.frame.size.height - voiceHeight) / 2,
                                               voiceWidth, voiceHeight);
        
        xOffset = fullWidth-(size.width)-kAvatarAll-kArrowWidth-kTextLeftSideMargin;
        self.durationLabel.frame = CGRectMake(self.bgImageView.frame.origin.x - kTextLeftSideMargin / 2 - size.width, yOffset+kTextImageYMargin+kImageTopMargin, size.width, size.height);
        
        loadingRect = CGRectMake(self.bgImageView.frame.origin.x-16, self.bgImageView.frame.origin.y, 16, 16);
    }
    
//    self.tapMaskView.frame = self.bgImageView.frame;
//    [self.contentView bringSubviewToFront:self.tapMaskView];
    
    self.loadingView.frame = loadingRect;
    self.retryButton.frame = loadingRect;
    
    self.durationLabel.text = text;
    
    
}

+ (CGFloat)cellHeightWithMessage:(Message*)message
{
    VoiceMessage* textMessage = (VoiceMessage*)message;
    NSString* text = [NSString stringWithFormat:@"%d\"", textMessage.duration];
    
    UIFont* font = [UIFont systemFontOfSize:kTextFontSize];
    CGFloat maxTextWidth = kMaxMessageWidth-kArrowWidth-kTextLeftSideMargin-kTextRightSideMargin;
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxTextWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    size.height = ceil(size.height);
    
    return size.height+(kTextImageYMargin+kImageTopMargin)*2;
}

@end
