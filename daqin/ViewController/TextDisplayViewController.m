//
//  BXTextDisplayViewController.m
//  Baixing
//
//  Created by minjie on 14-5-16.
//
//

#import "TextDisplayViewController.h"
#import "Message.h"

@interface TextDisplayViewController ()

@property (nonatomic, strong) UILabel *displayLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TextDisplayViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = self.view.bounds;
    self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];

    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];

    self.displayLabel = [[UILabel alloc] initWithFrame:self.scrollView.bounds];
    self.displayLabel.numberOfLines = 0;
    self.displayLabel.font = [UIFont systemFontOfSize:26.0f];
    self.displayLabel.textColor = [UIColor blackColor];
    self.displayLabel.textAlignment = NSTextAlignmentCenter;
    self.displayLabel.userInteractionEnabled = YES;
    self.displayLabel.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.displayLabel];
    
    self.displayLabel.text = [self.message textValue];
    [self.displayLabel sizeToFit];
    if (self.displayLabel.frame.size.height < self.scrollView.bounds.size.height) {
        self.displayLabel.frame = self.scrollView.bounds;
    }
    self.scrollView.contentSize = CGSizeMake(self.displayLabel.frame.size.width, self.displayLabel.frame.size.height);

}

- (void)dealloc {
    self.displayLabel = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)handleTapGesture
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
