//
//  PostViewController.m
//  daqin
//
//  Created by BurizaDo on 7/23/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "PostViewController.h"
#import "InputCell.h"
#import "EGOCache.h"
#import "SVProgressHUD.h"
#import "QQHelper.h"
#import "LoginViewController.h"
#import "HttpClient.h"
#import "EventDefinition.h"
#import "DateSelectViewController.h"

@interface PostViewController ()  <UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate, DateSelectDelegate>
@property (nonatomic, assign) UITextField* destination;
@property (nonatomic, assign) UITextField* describe;
@property (nonatomic, assign) UITextField* startTime;
@property (nonatomic, assign) UITextField* endTime;
@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, copy) NSDate* endDate;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) BOOL isStartTime;
@end

@implementation PostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tableView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _insets = self.tableView.contentInset;
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    if (keyboardBounds.origin.x != 0)
    {
        return;
    }
    self.tableView.contentInset =  UIEdgeInsetsMake(-20, 0, 20, 0);
    
//    UIView *input = [BXUtil findFirstResponder:self.view];
//    if ([input isKindOfClass:[UITextField class]] || [input isKindOfClass:[UITextView class]])
//    {
//        NSIndexPath *indexPath = [self indexPathForCellContainingView:input];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    }
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    self.tableView.contentInset = _insets;//(UIEdgeInsets){0, 0, 0, 0};
}

-(void)hideKeyboard{
    [self.destination resignFirstResponder];
    [self.describe resignFirstResponder];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideKeyboard];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kInputCell"];
    if (!cell) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"InputCell" owner:nil options:nil];
        cell = nib[0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(indexPath.row == 0){
        cell.nameLabel.text = @"我要去：";
        cell.textField.placeholder = @"拉萨，丽江，鼓浪屿...";
        _destination = cell.textField;
        [cell.textField addTarget:self action:@selector(textFieldClick:) forControlEvents:UIControlEventTouchDown];

    }else if(indexPath.row == 1){
        cell.nameLabel.text = @"到达时间：";
        cell.textField.userInteractionEnabled = NO;
        _startTime = cell.textField;
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startCellTapGesture)];
        [cell addGestureRecognizer:gesture];
    }else if(indexPath.row == 2){
        cell.nameLabel.text = @"离开时间：";
        cell.textField.userInteractionEnabled = NO;
        _endTime = cell.textField;
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endCellTapGesture)];
        [cell addGestureRecognizer:gesture];
    }else if(indexPath.row == 3){
        cell.nameLabel.text = @"备注：";
        cell.textField.placeholder = @"求拼车、结伴、喝茶";
        _describe = cell.textField;
    }
    return cell;
}

- (void)pushDateController{
    DateSelectViewController* date = [[DateSelectViewController alloc] init];
    date.delegate = self;
    [self.navigationController pushViewController:date animated:YES];
}

- (void)endCellTapGesture{
    [self hideKeyboard];
    _isStartTime = NO;
    [self pushDateController];
}

- (void)startCellTapGesture{
    [self hideKeyboard];
    _isStartTime = YES;
    [self pushDateController];
}

- (void)handleDateChange:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    if(_isStartTime){
        _startTime.text = [formatter stringFromDate:date];
        _startDate = date;
    }else{
        _endTime.text = [formatter stringFromDate:date];
        _endDate = date;
    }
}

-(void)textFieldClick:(id)sender{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *footView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//    footView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
//    return footView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    UIButton *post = [UIButton buttonWithType:UIButtonTypeCustom];
    [post setTitle:@"发  布" forState:UIControlStateNormal];
    [post setImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    post.titleEdgeInsets = UIEdgeInsetsMake(0, -290, 0, 0);
    post.frame=CGRectMake(10, 30, 300, 40);
    [post addTarget:self action:@selector(doPost) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:post];
    
    return footerView;
}

-(void)reset{
    _destination.text = @"";
    _describe.text = @"";
    [self hideKeyboard];
}

-(BOOL)checkData{
    BOOL error = YES;
    if([_destination.text isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:@"请填写目的地"];
        error = NO;
    }else if([_startTime.text isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:@"请填写到达日期"];
        error = NO;
    }else if([_endTime.text isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:@"请填写离开日期"];
        error = NO;
    }
    return error;
}

-(void)doPost{
    if(![self checkData]) return;
    [SVProgressHUD showWithStatus:@"发布中..."];
    NSDictionary* dic = @{@"userId":[[EGOCache globalCache] objectForKey:@"userToken"],
                          @"destination":_destination.text,
                          @"start_time":[NSString stringWithFormat:@"%d",(int)[_startDate timeIntervalSince1970]],
                          @"end_time":[NSString stringWithFormat:@"%d",(int)[_endDate timeIntervalSince1970]],
                          @"message":_describe.text};
    [[HttpClient sharedClient] getAPI:@"addMessage" params:dic success:^(id obj) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPostSucceed object:nil];
        [self reset];
        [SVProgressHUD dismiss];
    } failure:^(Error *errMsg) {
        [SVProgressHUD dismiss];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
