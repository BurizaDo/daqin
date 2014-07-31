//
//  ProfileViewController.m
//  daqin
//
//  Created by BurizaDo on 7/30/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ProfileViewController.h"
#import <UIImageView+WebCache.h>
#import "User.h"
#import "UserProvider.h"
#import "EGOCache.h"
#import "LoginViewController.h"

@interface ProfileViewController ()
@property (nonatomic, copy) User* user;
@end

@implementation ProfileViewController

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
    if(imageUrls.count < 10){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, size, size)];
        iv.image = [UIImage imageNamed:@"more_plus"];
        [_imagesView addSubview:iv];
        x += size + 5;
    }
    _imagesView.contentSize = CGSizeMake(x, frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(!_user){
        NSString* userId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
        [UserProvider getUsers:userId onSuccess:^(NSArray *users) {
            if([users count] == 0) return;
            _user = users[0];
            if([_user.avatar length] > 0){
                [_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar]];
            }
            _name.text = _user.name;
            _signature.text = _user.signature;
            _age.text = [_user.age stringByAppendingString:@"岁"];
            if(_user.images.length > 0){
                [self setupImageScrollView:[_user.images componentsSeparatedByString:@","]];
            }
            
        } onFailure:^(NSString *error) {
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
