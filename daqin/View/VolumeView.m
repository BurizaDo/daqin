//
//  VolumenView.m
//  Baixing
//
//  Created by XuMengyi on 14-6-23.
//
//

#import "VolumeView.h"

@interface VolumenView()
@property(nonatomic, strong) UIImageView* microPhone;
@property(nonatomic, strong) UIImageView* volumeView;
@end

@implementation VolumenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        UIImage* microPhone = [UIImage imageNamed:@"voice_rcd_hint.png"];
        UIImage* volume = [UIImage imageNamed:@"amp1.png"];
        
        self.microPhone = [[UIImageView alloc] init];
        self.volumeView = [[UIImageView alloc] init];
        self.microPhone.image = microPhone;
        self.volumeView.image = volume;
        [self addSubview:self.microPhone];
        [self addSubview:self.volumeView];
        
        self.microPhone.frame = CGRectMake((self.frame.size.width - (microPhone.size.width / 2 + volume.size.width / 2)) / 2,
                                           (self.frame.size.height - microPhone.size.height / 2) / 2,
                                            microPhone.size.width / 2, microPhone.size.height / 2);
        self.volumeView.frame = CGRectMake(self.microPhone.frame.origin.x + self.microPhone.frame.size.width,
                                           (self.frame.size.height - microPhone.size.height / 2) / 2,
                                           volume.size.width / 2, volume.size.height / 2);

    }
    return self;
}

- (void) updatePower:(float)power{
    NSString* img = [NSString stringWithFormat:@"amp%d.png", 1 + (int)(power / (1.0 / 7))];
    self.volumeView.image = [UIImage imageNamed:img];
}

@end
