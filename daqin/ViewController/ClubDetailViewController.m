//
//  RouteDetailViewController.m
//  daqin
//
//  Created by BurizaDo on 7/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ClubDetailViewController.h"
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
#import "CommentsProvider.h"
#import "Comment.h"
#import "SimpleInputView.h"
#import "CommentsTableViewCell.h"
#import "CommentsViewController.h"

@interface ClubDetailViewController () <MWPhotoBrowserDelegate, InputDelegate>
@property (nonatomic, weak) IBOutlet UILabel* seperator2;
@property (strong, nonatomic) IBOutlet UIView *commandView;
@property (weak, nonatomic) IBOutlet UIButton *beentoBtn;
@property (weak, nonatomic) IBOutlet UIButton *message;
@property (assign, nonatomic) BOOL hasBeenTo;
@property (nonatomic, strong) SimpleInputView* inputView;
@property (nonatomic, strong) UIView* commentsContainer;
@end

@implementation ClubDetailViewController

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
        [btn setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
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
    return [_club.images count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    NSString* url = _club.images[index];
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
    _name.text = _club.name;
    _address.text = _club.address;
    UIColor* colorF = [UIColor colorWithRed:255/255.0 green:172/255.0 blue:184/255.0 alpha:1];
    UIColor* colorM = [UIColor colorWithRed:172/255.0 green:215/255.0 blue:255/255.0 alpha:1];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

//    NSString* startTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_route.startTime.intValue]];
//    
//    NSString* endTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_route.endTime.intValue]];
    
//    NSString* schedule = [startTime stringByAppendingString:@" 至 "];
//    schedule = [schedule stringByAppendingString:endTime];
    
    if([_club.images count] > 0){
        [self setupImageScrollView:_route.images];
    }
    
//    [_chatButton addTarget:self action:@selector(chatClicked) forControlEvents:UIControlEventTouchUpInside];
 
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:(UIBarButtonItemStyleBordered) target:self action:@selector(report)];
    
//    [self handleMarkSucceed];
    
//    User* user = [GlobalDataManager sharedInstance].user;
//    if(user){
//        [ListingProvider hasBeenTo:user.userId messageId:_route.routeId onSuccess:^(id object) {
//            _hasBeenTo = [((NSNumber*)object) boolValue];
//        } onFailure:^(Error *error) {
//            
//        }];
//    }
//    
//    [_beentoBtn addTarget:self action:@selector(doMark) forControlEvents:UIControlEventTouchUpInside];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboardNotification:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [_scrollView addGestureRecognizer:gesture];

    [self showComments];
}

- (void)showComments{
//    [CommentsProvider getCommentsMessageId:_route.routeId from:0 size:3 onSuccess:^(NSArray *responseArray){
//        if(_commentsContainer == nil){
//            _commentsContainer = [[UIView alloc] init];
//        }
//        [[_commentsContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        CGFloat y = 0;
//        for(Comment* cmt in responseArray){
//            CommentsTableViewCell* cell = [[NSBundle mainBundle] loadNibNamed:@"CommentsTableViewCell" owner:nil options:nil][0];
//            [cell adaptWithComment:cmt];
//            [_commentsContainer addSubview:cell];
//            cell.frame = CGRectMake(0, y, cell.bounds.size.width, cell.bounds.size.height);
//            y += cell.frame.size.height + 1;
//        }
//        if(y > 0){
//            UIButton* cmtBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, y + 5, 300, 30)];
//            [cmtBtn setTitle:@"查看更多" forState:UIControlStateNormal];
//            [cmtBtn setBackgroundColor:[UIColor colorWithRed:32/255.0 green:152/255.0 blue:214/255.0 alpha:1]];
//            [cmtBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [_commentsContainer addSubview:cmtBtn];
//            y += cmtBtn.frame.size.height;
//            [cmtBtn addTarget:self action:@selector(moreComments) forControlEvents:UIControlEventTouchUpInside];
//        }
//        if(y > 0){
//            CGFloat orignY = _route.user.images.length > 0 ?
//            _imagesView.frame.origin.y + _imagesView.frame.size.height + 10:
//            _seperator2.frame.origin.y + _seperator2.frame.size.height + 10;
//            _commentsContainer.frame = CGRectMake(0, orignY, 320, y);
//            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _commentsContainer.frame.origin.y + _commentsContainer.frame.size.height + _commandView.frame.size.height + 20);
//            [_scrollView addSubview:_commentsContainer];
//        }else{
//            [_commentsContainer removeFromSuperview];
//        }
//
//    } onFailure:^(Error *error) {
//        
//    }];
}

- (void)moreComments{
//    CommentsViewController* vc = [[CommentsViewController alloc] initWithNibName:@"CommentsViewController" bundle:nil];
//    vc.routeId = _route.routeId;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)hideKeyboard{
    if(_inputView){
        [_inputView.textView resignFirstResponder];
        [_inputView removeFromSuperview];
    }
}

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSInteger animationCurveOption = (curve << 16);
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:animationCurveOption
                     animations:^
     {
         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
         
         CGRect inputViewFrame = _inputView.frame;
         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
         
         _inputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                  inputViewFrameY,
                                                  inputViewFrame.size.width,
                                                  inputViewFrame.size.height);
         
//         [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
     } completion:^(BOOL finished) {
     }];
}

- (void)handleMarkSucceed{
//    [ListingProvider getMarkedCount:_route.routeId onSuccess:^(id object) {
//        NSString* count = [NSString stringWithFormat:@"(%@)", object];
//        [_beentoBtn setTitle:[@"去过" stringByAppendingString:count] forState:UIControlStateNormal];
//    } onFailure:^(Error *error) {
//        
//    }];

}

- (void)doMark{
//    User* user = [GlobalDataManager sharedInstance].user;
//    if(!user){
//        LoginViewController* vc = [[LoginViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        [ListingProvider markAsBeento:user.userId messageId:_route.routeId hasBeento:!_hasBeenTo onSuccess:^{
//            _hasBeenTo = !_hasBeenTo;
//            [self handleMarkSucceed];
//        } onFailure:^(Error *error) {
//            
//        }];
//    }
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
//    MessageViewController* messageVC = [MessageViewController new];
//    messageVC.receiverChatUser = [[ChatUser alloc] initWithPeerId:_route.user.userId displayName:_route.user.name iconUrl:_route.user.avatar];
//    [ChatSession sharedInstance].receiverUser = messageVC.receiverChatUser;
//    [messageVC initData];
//
//    [self.navigationController pushViewController:messageVC animated:YES];
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
    
    maximumLabelSize = CGSizeMake(_describe.frame.size.width, 999);
    _describe.numberOfLines = 100;
    CGSize expectDescSize = [_describe.text sizeWithFont:_describe.font constrainedToSize:maximumLabelSize lineBreakMode:_describe.lineBreakMode];
    _describe.frame = CGRectMake(_describe.frame.origin.x, _describe.frame.origin.y, _describe.frame.size.width, expectDescSize.height);

    CGRect descRect = _describe.frame;
    _seperator2.frame = CGRectMake(15, descRect.origin.y + descRect.size.height + 15, _seperator2.frame.size.width, _seperator2.frame.size.height);
    
    BOOL isImage = _route.user.images.length > 0;


    CGRect superRect = [_scrollView superview].frame;

    if(isImage){
        _imagesView.frame = CGRectMake(0, _seperator2.frame.origin.y + _seperator2.frame.size.height + 15, 320, 100);
        float y = _imagesView.frame.origin.y + _imagesView.frame.size.height + _commandView.frame.size.height + 15;
        if(_commentsContainer == nil){
            _scrollView.contentSize = CGSizeMake(superRect.size.width, y);
        }else{
            _scrollView.contentSize = CGSizeMake(superRect.size.width, _commentsContainer.frame.origin.y + _commentsContainer.frame.size.height + _commandView.frame.size.height + 20);
        }
    }else{
        _imagesView.hidden = YES;
        
    }
    
    [self.view addSubview:_commandView];
    _commandView.frame = CGRectMake((self.view.frame.size.width - _commandView.frame.size.width)/2,
                                    self.view.frame.size.height - _commandView.frame.size.height - 5,
                                    _commandView.frame.size.width,
                                    _commandView.frame.size.height);
    [_message addTarget:self action:@selector(doComment) forControlEvents:UIControlEventTouchUpInside];
    _chatButton.frame = CGRectMake(177, 12, 114, 30);
}

- (void)doComment{
    if(!_inputView){
        CGRect inputFrame = CGRectMake(0, self.view.frame.size.height - 40, 320, 40);
        _inputView = [[SimpleInputView alloc] initWithFrame:inputFrame];
        _inputView.messageDelegate = self;
    }
    if(_inputView.superview == nil){
        [self.view addSubview:_inputView];
    }
    [_inputView.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InputDelegate
- (void)onSendMessage:(NSString *)text{
    [self hideKeyboard];
    NSDate* current = [NSDate date];
    NSTimeInterval time = [current timeIntervalSince1970];
    [CommentsProvider commitCommentMessageId:_route.routeId userId:[GlobalDataManager sharedInstance].user.userId replyId:nil message:text timestamp:[NSString stringWithFormat:@"%ld", (long)time] onSuccess:^{
        [self showComments];
    } onFailure:^(Error *error) {
        
    }];
}

@end
