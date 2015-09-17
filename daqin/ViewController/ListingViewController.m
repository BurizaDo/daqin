//
//  ListingViewController.m
//  daqin
//
//  Created by BurizaDo on 7/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ListingViewController.h"
#import <UIImageView+WebCache.h>
#import "ListingProvider.h"
#import "SVPullToRefresh.h"
#import "ClubCell.h"
#import "Club.h"
#import "RouteDetailViewController.h"
#import "Uploader.h"
#import "GlobalDataManager.h"
#import "ViewUtil.h"

@interface ListingViewController ()
@property (nonatomic, strong) NSMutableArray* clubs;
@end

@implementation ListingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadData:(BOOL)stopAnimation from:(int)from{
    [ListingProvider getAllClubsLongitude:31.186053 latitude:121.447579 onSuccess:^(NSArray *responseArray) {
        _clubs = [NSMutableArray arrayWithArray:responseArray];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData:NO from:0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    __weak ListingViewController* wlv = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [wlv loadData:YES from:0];
    }];

    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if(wlv.clubs.count % 30 == 0){
            [wlv loadData:YES from:wlv.clubs.count];
        }else{
            [wlv.tableView.infiniteScrollingView stopAnimating];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _clubs == nil ? 0 : [_clubs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClubCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kClubCell"];
    
    if(!cell){
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"ClubCell" owner:nil options:nil];
        cell = nib[0];
    }
    Club* club = _clubs[indexPath.row];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MM/dd"];
//    NSString* start = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[route.startTime intValue]]];
//    NSString* end = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[route.endTime intValue]]];
//    NSString* schedule = [start stringByAppendingString:@" 至 "];
//    schedule = [schedule stringByAppendingString:end];
    cell.name.text = club.name;
    cell.address.text = club.address;
    
    if(club.images != nil && club.images.count > 0){
//        [cell.avatar.layer setCornerRadius:(CGRectGetHeight(cell.avatar.bounds))/2];
//        cell.avatar.clipsToBounds = YES;
        [cell.avatar setImageWithURL:[NSURL URLWithString:club.images[0]]];
    }
    if(indexPath.row % 2 != 0){
        cell.backgroundColor = [UIColor colorWithRed:0xf8/255.0 green:0xf8/255.0 blue:0xf8/255.0 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    Route* route = _routes[indexPath.row];
//    RouteDetailViewController* detail = [[RouteDetailViewController alloc] initWithNibName:@"RouteDetailViewController" bundle:nil];
//    detail.hidesBottomBarWhenPushed = YES;
//    detail.route = route;
//    [self.navigationController pushViewController:detail animated:YES];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [ListingProvider deleteUserMessage:[GlobalDataManager sharedInstance].user.userId msgId:((Route*)_routes[indexPath.row]).routeId onSuccess:^{
//            
//        } onFailure:^(Error *error) {
//            
//        }];
//        [_routes removeObjectAtIndex:indexPath.row];
//        [tableView beginUpdates];
//        [tableView deleteRowsAtIndexPaths:@[indexPath]
//                         withRowAnimation:UITableViewRowAnimationAutomatic];
//        [tableView endUpdates];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
