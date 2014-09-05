//
//  BXTextMessageCell.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "TextMessageCell.h"
#import "TextMessage.h"
#import "EmotionUtil.h"
#import "EmotionData.h"
#import "MarkUpParser.h"
#import "SCGIFImageView.h"
#import "NSAttributedString+Attributes.h"

#define kArrowWidth             10.0f
#define kTextLeftSideMargin     10.0f
#define kTextRightSideMargin    15.0f
#define kTextImageYMargin       10.0f
#define kImageTopMargin         10.0f
#define kTextFontSize           16.0f
#define kTextAvatarMargin       5.0f

#define EMOTION_SIZE            18

@implementation TextMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier target:target];
    if (self) {
        
        self.bgImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:self.bgImageView];
        self.titleLabel = [[OHAttributedLabel alloc] init];
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
    self.bgImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 20, 15, 20)];
    
    CGFloat maxTextWidth = kMaxMessageWidth-kArrowWidth-kTextLeftSideMargin-kTextRightSideMargin;
    
    for(UIView* sub in [self.titleLabel subviews]) {
        [sub removeFromSuperview];
    }
    [TextMessageCell setAttributedLabel:[TextMessageCell transformString:text] Label:self.titleLabel maxTextWidth:maxTextWidth];
    CGSize size = self.titleLabel.frame.size;
    
    CGRect loadingRect;
    
    if (self.messageDirection == MessageDirectionLeft) {
        self.bgImageView.frame = CGRectMake(kAvatarAll + kTextAvatarMargin, yOffset+kImageTopMargin, kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+size.width, size.height+kTextImageYMargin*2);
        self.titleLabel.frame = CGRectMake(kAvatarAll+kArrowWidth+kTextLeftSideMargin, yOffset+kTextImageYMargin+kImageTopMargin, size.width, size.height);
        
        loadingRect = CGRectMake(self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width, self.bgImageView.frame.origin.y, 16, 16);
    }
    else{
        
        CGFloat fullWidth = self.frame.size.width;
        CGFloat xOffset = fullWidth-(kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+size.width)-kAvatarAll - kTextAvatarMargin;
        self.bgImageView.frame = CGRectMake(xOffset, yOffset+kImageTopMargin, kArrowWidth+kTextLeftSideMargin+kTextRightSideMargin+size.width, size.height+kTextImageYMargin*2);
        
        xOffset = fullWidth-(size.width)-kAvatarAll-kArrowWidth-kTextLeftSideMargin;
        self.titleLabel.frame = CGRectMake(xOffset, yOffset+kTextImageYMargin+kImageTopMargin, size.width, size.height);
        
        loadingRect = CGRectMake(self.bgImageView.frame.origin.x-16, self.bgImageView.frame.origin.y, 16, 16);
    }
    
    self.tapMaskView.frame = self.bgImageView.frame;
    [self.contentView bringSubviewToFront:self.tapMaskView];
    
    self.loadingView.frame = loadingRect;
    self.retryButton.frame = loadingRect;
}

+ (void)setAttributedLabel:(NSString *)str Label:(OHAttributedLabel *)label maxTextWidth:(CGFloat)maxTextWidth {
    [label setNeedsDisplay];
    
    MarkUpParser* parser = [[MarkUpParser alloc] init];
    NSMutableAttributedString* attString = [parser attrStringFromMarkUp:str];
    
    [attString setFont:[UIFont systemFontOfSize:kTextFontSize]];
    [label setBackgroundColor:[UIColor clearColor]];
    
    [label setAttString:attString withImages:parser.images];
    
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(maxTextWidth, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(maxTextWidth, CGFLOAT_MAX)].height;
    
    label.frame = labelRect;
    
    [label.layer display];
    
    for (NSArray *info in label.imageInfoArr) {
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectFromString([info objectAtIndex:2]);
        [imageView setImage:[UIImage imageNamed:[info objectAtIndex:0]]];
        [label addSubview:imageView];//label内添加图片层
        [label bringSubviewToFront:imageView];
    }
}

+ (NSString *)transformString:(NSString *)originalStr
{
    //匹配表情，将表情转化为html格式
    NSString* text = originalStr;
    NSArray *matches = [EmotionUtil findEmojiInStr:text range:NSMakeRange(0, [text length])];
    if(nil == matches) {
        return text;
    }
    NSMutableArray* results = [[NSMutableArray alloc] init];
    for(NSTextCheckingResult* match in matches) {
        [results addObject:[text substringWithRange:[match range]]];
    }
    for(NSString* str in results) {
        EmotionData* emotion = [EmotionUtil findEmotionByStr:str];
        if(nil != emotion) {
            NSRange range = [text rangeOfString:str];
            NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='%d' height='%d'>", emotion.emotionImg, EMOTION_SIZE, EMOTION_SIZE];
            text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
        }
    }
    //返回转义后的字符串
    return text;
}

+ (CGFloat)cellHeightWithMessage:(Message*)message
{
    TextMessage* textMessage = (TextMessage*)message;
    NSString* text = textMessage.text;
    
    CGFloat maxTextWidth = kMaxMessageWidth-kArrowWidth-kTextLeftSideMargin-kTextRightSideMargin;
    // 这里new了个label，感觉非常不好。。。以后想个办法把size的计算写成static的吧
    OHAttributedLabel* label = [[OHAttributedLabel alloc] init];
    [TextMessageCell setAttributedLabel:[TextMessageCell transformString:text] Label:label maxTextWidth:maxTextWidth];
    CGSize size = label.frame.size;
    
    return size.height+(kTextImageYMargin+kImageTopMargin)*2;
}

@end
