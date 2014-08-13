//
//  BXVoiceMessageCell.h
//  Baixing
//
//  Created by XuMengyi on 14-6-20.
//
//

#import "MessageCell.h"

@interface VoiceMessageCell : MessageCell
@property (nonatomic,strong) UIButton*   bgImageView;
@property (nonatomic,strong) UIImageView*   voiceImageView;
@property (nonatomic, strong) UILabel* durationLabel;
@end
