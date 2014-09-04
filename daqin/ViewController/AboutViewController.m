//
//  AboutViewController.m
//  daqin
//
//  Created by BurizaDo on 9/1/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "AboutViewController.h"
#import "ViewUtil.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@end

@implementation AboutViewController

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
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString* v = @"当前版本：";
    _versionLabel.text = [v stringByAppendingString:version];
    _logo.layer.cornerRadius = 30.f;
    _logo.layer.masksToBounds = YES;
    self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(handleBack)];
    self.title = @"关于";
}

-(void)handleBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
