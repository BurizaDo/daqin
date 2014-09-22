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
#import "GlobalDataManager.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "LoginViewController.h"
#import "ReportViewController.h"
#import "ListingProvider.h"

@interface RouteDetailViewController () <MWPhotoBrowserDelegate>
@property (nonatomic, weak) IBOutlet UILabel* seperator2;
@property (strong, nonatomic) IBOutlet UIView *commandView;
@property (weak, nonatomic) IBOutlet UIButton *beentoBtn;
@property (weak, nonatomic) IBOutlet UIButton *message;
@property (assign, nonatomic) BOOL hasBeenTo;
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
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:(UIBarButtonItemStyleBordered) target:self action:@selector(report)];
    
    [self handleMarkSucceed];
    
    User* user = [GlobalDataManager sharedInstance].user;
    if(user){
        [ListingProvider hasBeenTo:user.userId messageId:_route.routeId onSuccess:^(id object) {
            _hasBeenTo = [((NSNumber*)object) boolValue];
        } onFailure:^(Error *error) {
            
        }];
    }
    
    [_beentoBtn addTarget:self action:@selector(doMark) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleMarkSucceed{
    [ListingProvider getMarkedCount:_route.routeId onSuccess:^(id object) {
        NSString* count = [NSString stringWithFormat:@"(%@)", object];
        [_beentoBtn setTitle:[@"去过" stringByAppendingString:count] forState:UIControlStateNormal];
    } onFailure:^(Error *error) {
        
    }];

}

- (void)doMark{
    User* user = [GlobalDataManager sharedInstance].user;
    if(!user){
        LoginViewController* vc = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [ListingProvider markAsBeento:user.userId messageId:_route.routeId hasBeento:!_hasBeenTo onSuccess:^{
            _hasBeenTo = !_hasBeenTo;
            [self handleMarkSucceed];
        } onFailure:^(Error *error) {
            
        }];
    }
}

- (void)report{
    ReportViewController* rvc = [[ReportViewController alloc] init];
    [self.navigationController pushViewController:rvc animated:YES];
}

- (void)chatClicked{
    if([GlobalDataManager sharedInstance].user == nil){
        LoginViewController* lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        lvc.title = @"登录";
        lvc.hasBack = YES;
        [self.navigationController pushViewController:lvc animated:YES];
        return;
    }
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
    
    BOOL isImage = _route.user.images.length > 0;


    CGRect superRect = [_scrollView superview].frame;

    if(isImage){
        _imagesView.frame = CGRectMake(0, _seperator2.frame.origin.y + _seperator2.frame.size.height + 15, 320, 100);
        float y = _imagesView.frame.origin.y + _imagesView.frame.size.height + _commandView.frame.size.height + 15;
        _scrollView.contentSize = CGSizeMake(superRect.size.width, y);
    }else{
        _imagesView.hidden = YES;
        
    }
    
    [self.view addSubview:_commandView];
    _commandView.frame = CGRectMake((self.view.frame.size.width - _commandView.frame.size.width)/2,
                                    self.view.frame.size.height - _commandView.frame.size.height - 5,
                                    _commandView.frame.size.width,
                                    _commandView.frame.size.height);
    _chatButton.frame = CGRectMake(177, 12, 114, 30);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
