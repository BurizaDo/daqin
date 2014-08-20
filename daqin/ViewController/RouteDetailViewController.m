//
//  RouteDetailViewController.m
//  daqin
//
//  Created by BurizaDo on 7/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "RouteDetailViewController.h"
#import <UIImageView+WebCache.h>
#import "UIButton+WebCache.h"
#import "MWPhotoBrowser.h"
#import "ChatUser.h"
#import "MessageViewController.h"
#import "ChatSession.h"
#import "ViewUtil.h"

@interface RouteDetailViewController () <MWPhotoBrowserDelegate>
@property (nonatomic, weak) IBOutlet UILabel* seperator2;
@property (nonatomic, weak) IBOutlet UILabel* seperator3;
@end

@implementation RouteDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"详情";
        self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(backAction)];
    }
    return self;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupImageScrollView:(NSArray*) imageUrls{
    CGRect frame = _imagesView.frame;
    int size = frame.size.height - 5 * 2;
    float y = 5;
    float x = 5;
    for(int i = 0; i < imageUrls.count; ++ i){
        NSString* url = imageUrls[i];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, size, size);
        [btn sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
        btn.tag = i;
        [[btn layer] setCornerRadius:4.0];
        [btn layer].masksToBounds = YES;
        [btn addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];

        x += size + 5;
        [_imagesView addSubview:btn];
    }
    _imagesView.contentSize = CGSizeMake(x, frame.size.height);
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return [_route.user.images componentsSeparatedByString:@","].count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    NSString* url = [_route.user.images componentsSeparatedByString:@","][index];
    return [MWPhoto photoWithURL:[NSURL URLWithString:url]];
}


- (void)imageClicked:(id)sender{
    UIButton* btn = sender;
    
    MWPhotoBrowser *imgBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    imgBrowser.displayActionButton = YES;
    imgBrowser.wantsFullScreenLayout = YES;
    imgBrowser.zoomPhotosToFill = YES;
    [imgBrowser setCurrentPhotoIndex:btn.tag];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imgBrowser];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];

}

- (UIImage*)splitImage:(UIImage*) image frame:(CGRect)frame{
    CGImageRef img =CGImageCreateWithImageInRect(image.CGImage, frame);
    UIImage* splitImage = [UIImage imageWithCGImage:img];
    CGImageRelease(img);
    return splitImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(_route.user.avatar.length > 0){
        [_avatar sd_setImageWithURL:[NSURL URLWithString:_route.user.avatar]];
    }
    [_avatar.layer setCornerRadius:CGRectGetHeight(_avatar.bounds)/2];
    _avatar.layer.masksToBounds = YES;
    _name.text = _route.user.name;
    _signature.text = _route.user.signature;
    _destination.text = _route.destination;
    _description.text = _route.description;
    _age.text = _route.user.age;
    _age.text = [_age.text stringByAppendingString:@"岁"];
    _age.layer.cornerRadius = _age.bounds.size.height / 2;
    _iv_dest.image = [UIImage imageNamed:@"detail_01"];
    _iv_time.image = [UIImage imageNamed:@"detail_02"];
    _iv_desc.image = [UIImage imageNamed:@"detail_03"];
    UIColor* colorF = [UIColor colorWithRed:255/255.0 green:172/255.0 blue:184/255.0 alpha:1];
    UIColor* colorM = [UIColor colorWithRed:172/255.0 green:215/255.0 blue:255/255.0 alpha:1];
    if([_route.user.gender isEqualToString:@"男"]){
        _age.backgroundColor = colorM;
    }else{
        _age.backgroundColor = colorF;
    }
    
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
    
    [_chatButton addTarget:self action:@selector(chatClicked) forControlEvents:UIControlEventTouchUpInside];
    
//    UIImage* scenery = [UIImage imageNamed:@"scenery1.jpg"];
//    CGSize imageSize = scenery.size;
    
//    UIImage *scaledImage =
//    [UIImage imageWithCGImage:[scenery CGImage]
//                        scale:(scenery.scale * (imageSize.width/320))
//                  orientation:(scenery.imageOrientation)];
    
//    CGSize s = scaledImage.size;
//    float upHeight = 16 * imageSize.height / 39;
//    CGRect up = CGRectMake(0, 0, 640, 128);
//    UIImage* splitUp = [self splitImage:scenery frame:up];
//    CGRect r = self.navigationController.navigationBar.frame;
//    [self.navigationController.navigationBar setBackgroundImage:scenery forBarMetrics:UIBarMetricsDefault];

//    CGRect down = CGRectMake(0, 128, 640, 184);
//    UIImage* splitDown = [self splitImage:scenery frame:down];
//    _topBackground.image = scenery;
}

- (void)chatClicked{
    MessageViewController* messageVC = [MessageViewController new];
    messageVC.receiverChatUser = [[ChatUser alloc] initWithPeerId:_route.user.userId displayName:_route.user.name iconUrl:_route.user.avatar];
    [ChatSession sharedInstance].receiverUser = messageVC.receiverChatUser;
    [messageVC initData];

    [self.navigationController pushViewController:messageVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    CGSize maximumLabelSize = CGSizeMake(999,999);
    CGSize expectedLabelSize = [_name.text sizeWithFont:_name.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:_name.lineBreakMode];
    float totalWidth = _age.frame.size.width + expectedLabelSize.width + 3;
    CGRect nameRect = CGRectMake((320 - totalWidth)/2, _name.frame.origin.y, expectedLabelSize.width, _name.frame.size.height);
    _name.frame = nameRect;
    
    CGRect ageFrame = _age.frame;
    ageFrame.origin.x = nameRect.origin.x + nameRect.size.width + 3;
    _age.frame = ageFrame;
    
    maximumLabelSize = CGSizeMake(_description.frame.size.width, 999);
    _description.numberOfLines = 100;
    CGSize expectDescSize = [_description.text sizeWithFont:_description.font constrainedToSize:maximumLabelSize lineBreakMode:_description.lineBreakMode];
    _description.frame = CGRectMake(_description.frame.origin.x, _description.frame.origin.y, _description.frame.size.width, expectDescSize.height);

    CGRect descRect = _description.frame;
    _seperator2.frame = CGRectMake(15, descRect.origin.y + descRect.size.height + 15, _seperator2.frame.size.width, _seperator2.frame.size.height);
    
    _imagesView.frame = CGRectMake(0, _seperator2.frame.origin.y + _seperator2.frame.size.height + 15, 320, 100);
    
    BOOL isImage = _route.user.images.length > 0;
    if(isImage){
        _seperator3.frame = CGRectMake(15, _imagesView.frame.origin.y + _imagesView.frame.size.height + 15, _seperator3.frame.size.width, _seperator3.frame.size.height);
        _chatButton.frame = CGRectMake(_chatButton.frame.origin.x, _seperator3.frame.origin.y + _seperator3.frame.size.height + 15, _chatButton.frame.size.width, _chatButton.frame.size.height);
    }else{
        _seperator3.hidden = YES;
        _imagesView.hidden = YES;
        _chatButton.frame = CGRectMake(_chatButton.frame.origin.x, _seperator2.frame.origin.y + _seperator2.frame.size.height + 15, _chatButton.frame.size.width, _chatButton.frame.size.height);
        
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
