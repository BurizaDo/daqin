//
//  BXMessageCell.h
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

@class Message;

#define kAvatarMargin   10.0f
#define kAvatarAll      (kAvatarMargin+kAvatarWidth)
#define kAvatarWidth    50.0f
#define kTimeHeight     30.0f

typedef NS_ENUM(NSInteger, MessageDirection)
{
    MessageDirectionLeft,
    MessageDirectionCenter,
    MessageDirectionRight,
};

#define kMaxMessageWidth  210.0f

@interface MessageCell : UITableViewCell

@property (nonatomic,assign) MessageDirection   messageDirection;

@property (nonatomic,strong) UIImageView*       avatarView;

@property (nonatomic,weak)   id                 gestureTarget;

@property (nonatomic,strong) UIView*            tapMaskView;

@property (nonatomic,strong) NSIndexPath*       indexPath;

@property (nonatomic,strong) UIActivityIndicatorView*   loadingView;

@property (nonatomic,strong) UIButton*                  retryButton;

@property (nonatomic,strong) UILabel*                  timeLabel;

/**
 *  长按手势
 */
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 *  点击手势
 */
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier target:(id)target;

+ (id)createMessageCellMessage:(Message*)message reuseIdentifier:(NSString *)reuseIdentifier target:(id)target;

+ (CGFloat)cellHeightWithMessage:(Message*)message;

- (void)configCellWithMessage:(Message*)message;

- (void)initGestureRecognizerWithTarget:(id)target;

@end
