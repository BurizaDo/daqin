//
//  BXTextMessageCell.h
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "MessageCell.h"
#import "OHAttributedLabel.h"

@interface TextMessageCell : MessageCell

@property (nonatomic,assign) BOOL           showTime;
@property (nonatomic,strong) UIImageView*   bgImageView;
@property (nonatomic,strong) OHAttributedLabel*       titleLabel;

@end
