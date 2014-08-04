//
//  RouteDetailViewController.m
//  daqin
//
//  Created by BurizaDo on 7/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "RouteDetailViewController.h"
#import <UIImageView+WebCache.h>

@interface RouteDetailViewController ()

@end

@implementation RouteDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupImageScrollView:(NSArray*) imageUrls{
    CGRect frame = _imagesView.frame;
    int size = frame.size.height - 5 * 2;
    float y = 5;
    float x = 5;
    for(NSString* url in imageUrls){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, size, size)];
        x += size + 5;
        [_imagesView addSubview:iv];
        [iv sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    _imagesView.contentSize = CGSizeMake(x, frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(_route.user.avatar.length > 0){
        [_avatar sd_setImageWithURL:[NSURL URLWithString:_route.user.avatar]];
    }
    _name.text = _route.user.name;
    _signature.text = _route.user.signature;
    _destination.text = _route.destination;
    _description.text = _route.description;
    _age.text = _route.user.age;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSString* startTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_route.startTime.intValue]];
    
    NSString* endTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_route.endTime.intValue]];
    
    NSString* schedule = [startTime stringByAppendingString:@" 至 "];
    schedule = [schedule stringByAppendingString:endTime];
    
    _schedule.text = schedule;
    
    if(_route.user.images.length > 0){
        [self setupImageScrollView:[_route.user.images componentsSeparatedByString:@","]];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    float y = _chatButton.frame.origin.y + _chatButton.frame.size.height + 15;
    CGRect superRect = [_scrollView superview].frame;
    _scrollView.contentSize = CGSizeMake(superRect.size.width, y);
    _scrollView.frame = CGRectMake(0, 0, superRect.size.width, superRect.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
