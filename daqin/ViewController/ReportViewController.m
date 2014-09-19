//
//  ReportViewController.m
//  daqin
//
//  Created by BurizaDo on 9/19/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ReportViewController.h"
#import "ViewUtil.h"
#import "SVProgressHUD.h"

@interface ReportViewController ()
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;

@end

@implementation ReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(doBack)];
    [_reportBtn addTarget:self action:@selector(doReport) forControlEvents:UIControlEventTouchUpInside];
}

- (void)doReport{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:@"举报成功" maskType:SVProgressHUDMaskTypeBlack];
        dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (void)doBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_content becomeFirstResponder];
}

@end
