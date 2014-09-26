//
//  CommentsViewController.m
//  daqin
//
//  Created by BurizaDo on 9/25/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "CommentsViewController.h"
#import "SVPullToRefresh.h"
#import "SimpleInputView.h"
#import "ViewUtil.h"
#import "CommentsProvider.h"
#import "CommentsTableViewCell.h"
#import "GlobalDataManager.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate, InputDelegate>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) SimpleInputView* inputView;
@property (nonatomic, strong) NSMutableArray* comments;
@property (nonatomic, strong) NSString* replyId;
@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"留言";
        self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(backAction)];
    }
    return self;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
//    [_tableView addGestureRecognizer:gesture];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView addPullToRefreshWithActionHandler:^{
        [self loadData:YES from:0];
    }];

    [_tableView addInfiniteScrollingWithActionHandler:^{
        if(_comments.count % 30 == 0){
            [self loadData:YES from:_comments.count];
        }else{
            [_tableView.infiniteScrollingView stopAnimating];
        }
 
    }];
    
    [CommentsProvider getCommentsMessageId:_routeId from:0 size:30 onSuccess:^(NSArray *responseArray){
        _comments = [NSMutableArray arrayWithArray:responseArray];
        [_tableView reloadData];
    } onFailure:^(Error *error) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboardNotification:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
}

- (void)handleWillShowKeyboardNotification:(NSNotification*)notification{
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

- (void)loadData:(BOOL)stopAnimation from:(int)from{
    [CommentsProvider getCommentsMessageId:_routeId from:from size:30 onSuccess:^(NSArray *areas) {
        if(from == 0){
            _comments = [NSMutableArray arrayWithArray:areas];
        }else{
            [_comments addObjectsFromArray:areas];
        }
        
        [self.tableView reloadData];
        if(stopAnimation){
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView.infiniteScrollingView stopAnimating];
        }
        
    } onFailure:^(Error *error) {
        if(stopAnimation){
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView.infiniteScrollingView stopAnimating];
        }
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    if(_inputView == nil){
        _inputView = [[SimpleInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
        [_inputView setBackgroundColor:[UIColor colorWithRed:32/255.0 green:152/255.0 blue:214/255.0 alpha:1]];
        [self.view addSubview:_inputView];
        _inputView.messageDelegate = self;
    }
    [super viewWillAppear:animated];
    _tableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 40);
}

- (void)hideKeyboard{
    [_inputView.textView resignFirstResponder];
    _inputView.frame = CGRectMake(0, self.view.frame.size.height - 40, 320, 40);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _comments == nil ? 0 : _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCommentsCell"];
    
    if(!cell){
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsTableViewCell" owner:nil options:nil];
        cell = nib[0];
    }
    [cell adaptWithComment:_comments[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_inputView.textView becomeFirstResponder];
    _replyId = ((Comment*)_comments[indexPath.row]).user.userId;
}


-(void)onSendMessage:(NSString*)text{
    [self hideKeyboard];
    NSDate* current = [NSDate date];
    NSTimeInterval time = [current timeIntervalSince1970];
    [CommentsProvider commitCommentMessageId:_routeId userId:[GlobalDataManager sharedInstance].user.userId replyId:_replyId message:text timestamp:[NSString stringWithFormat:@"%ld", (long)time] onSuccess:^{
        [self loadData:YES from:0];
    } onFailure:^(Error *error) {
        
    }];
    _replyId = nil;

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

@end
