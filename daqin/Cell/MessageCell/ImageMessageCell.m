//
//  BXImageMessageCell.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "ImageMessageCell.h"
#import "ImageMessage.h"
#import "Util.h"
#import "UIImageView+AFNetworking.h"

#define kMaxImageWidth          200.0f
#define kMaxImageHeight         100.0f
#define kImageTopMargin         10.0f
#define kBubbleLeftCapInsets    UIEdgeInsetsMake(30, 20, 10, 20)
#define kImageArrowMargin       7.0f

@implementation ImageMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier target:target];
    if (self) {
        
        self.photoView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.photoView];
        
        self.maskLayer = [CALayer layer];
        self.maskLayer.contentsScale = [UIScreen mainScreen].scale;
        self.maskLayer.contentsCenter = CGRectMake(0.5,0.7,0.1,0.1);
        
        [[self.photoView layer] setMask:self.maskLayer];
        
        [self initGestureRecognizerWithTarget:target];
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier target:nil];
    
    return self;
}

- (void)initGestureRecognizerWithTarget:(id)target
{
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(handleSingleHitGesture:)];
    [self.tapMaskView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)configCellWithMessage:(Message*)message
{
    [super configCellWithMessage:message];
    
    CGFloat yOffset = 0.0f;
    if (message.showTime) {
        yOffset = kTimeHeight;
    }
    
    UIImage* maskImage;
    if (self.messageDirection == MessageDirectionLeft){
        maskImage = [UIImage imageNamed:@"message_bg_receiving_pic"];
    }
    else{
        maskImage = [UIImage imageNamed:@"message_bg_sending_pic"];
    }
    self.maskLayer.contents = (id)maskImage.CGImage;

    
    __block CGSize size = CGSizeMake(100.0, 100.0);
    ImageMessage* imageMessage = (ImageMessage*)message;
    UIImage* image = imageMessage.image;
    
    __block CGRect loadingRect;
    
    if (image || (imageMessage.imageSize.width>0 && imageMessage.imageSize.height>0)) {
        CGSize imageSize = image ? image.size : imageMessage.imageSize;
        size = [Util scaleSize:imageSize maxSize:CGSizeMake(kMaxImageWidth, kMaxImageHeight)];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        if (image) {
            self.photoView.image = image;
        }
        else{
            [self.photoView setImageWithURL:[NSURL URLWithString:imageMessage.imageUrl] placeholderImage:[UIImage imageNamed:@"Public_Body_Icon_Loadpic.png"]];
        }
        
        
        if (self.messageDirection == MessageDirectionLeft) {
            self.photoView.frame = CGRectMake(kAvatarAll+kImageArrowMargin, yOffset+kImageTopMargin, size.width, size.height);
            self.maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
            
            loadingRect = CGRectMake(self.photoView.frame.origin.x+self.photoView.frame.size.width, self.photoView.frame.origin.y, 16, 16);
        }
        else{
            CGFloat fullWidth = self.frame.size.width;
            CGFloat xOffset = fullWidth-(size.width)-kAvatarAll;
            self.photoView.frame = CGRectMake(xOffset-kImageArrowMargin, yOffset+kImageTopMargin, size.width, size.height);
            self.maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
            
            loadingRect = CGRectMake(xOffset-16, self.photoView.frame.origin.y, 16, 16);
        }
        
    }
    else
    {
        __weak ImageMessageCell* weakSelf = self;
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageMessage.imageUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
        
        [self.photoView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"Public_Body_Icon_Loadpic.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            //save image to db
//            message
            
            weakSelf.photoView.image = image;
            
            
                    size = [Util scaleSize:image.size maxSize:CGSizeMake(kMaxImageWidth, kMaxImageHeight)];
            if (weakSelf.messageDirection == MessageDirectionLeft) {
                weakSelf.photoView.frame = CGRectMake(kAvatarAll+kImageArrowMargin, yOffset+kImageTopMargin, size.width, size.height);
                weakSelf.maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
                
                loadingRect = CGRectMake(weakSelf.photoView.frame.origin.x+weakSelf.photoView.frame.size.width, weakSelf.photoView.frame.origin.y, 16, 16);
            }
            else{
                CGFloat fullWidth = weakSelf.frame.size.width;
                CGFloat xOffset = fullWidth-(size.width)-kAvatarAll-kImageArrowMargin;
                weakSelf.photoView.frame = CGRectMake(xOffset, yOffset+kImageTopMargin, size.width, size.height);
                weakSelf.maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
                
                loadingRect = CGRectMake(xOffset-16, weakSelf.photoView.frame.origin.y, 16, 16);
            }

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        
        if (self.messageDirection == MessageDirectionLeft) {
            self.photoView.frame = CGRectMake(kAvatarAll+kImageArrowMargin, yOffset+kImageTopMargin, size.width, size.height);
            self.maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
            
            loadingRect = CGRectMake(self.photoView.frame.origin.x+self.photoView.frame.size.width, self.photoView.frame.origin.y, 16, 16);
        }
        else{
            CGFloat fullWidth = self.frame.size.width;
            CGFloat xOffset = fullWidth-(size.width)-kAvatarAll-kImageArrowMargin;
            self.photoView.frame = CGRectMake(xOffset, yOffset+kImageTopMargin, size.width, size.height);
            self.maskLayer.frame = CGRectMake(0, 0, size.width, size.height);
            
            loadingRect = CGRectMake(xOffset-16, self.photoView.frame.origin.y, 16, 16);
        }

    }
    
    
    self.tapMaskView.frame = self.photoView.frame;
    [self.contentView bringSubviewToFront:self.tapMaskView];
    
    self.loadingView.frame = loadingRect;
    self.retryButton.frame = loadingRect;
}

+ (CGFloat)cellHeightWithMessage:(Message*)message
{
    CGSize size = CGSizeMake(100.0, 100.0);
    ImageMessage* imageMessage = (ImageMessage*)message;
    UIImage* image = imageMessage.image;
    if (image) {
        size = [Util scaleSize:image.size maxSize:CGSizeMake(kMaxImageWidth, kMaxImageHeight)];
    }
    else if (imageMessage.imageSize.width>0 && imageMessage.imageSize.height>0){
        size = [Util scaleSize:imageMessage.imageSize maxSize:CGSizeMake(kMaxImageWidth, kMaxImageHeight)];
    }
    
    return ceil(size.height)+kImageTopMargin*2;
}

@end
