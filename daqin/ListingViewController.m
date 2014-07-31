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
#import "RouteCell.h"
#import "Route.h"
#import "RouteDetailViewController.h"

@interface ListingViewController ()
@property (nonatomic, strong) NSArray* routes;
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

- (void)loadData:(BOOL)stopAnimation{
    [ListingProvider getAllListingFrom:0 size:30 onSuccess:^(NSArray *areas) {
        _routes = areas;
        [self.tableView reloadData];
        if(stopAnimation){
            [self.tableView.pullToRefreshView stopAnimating];
        }

    } onFailure:^(NSString *error) {
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    __weak ListingViewController* wlv = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [wlv loadData:YES];
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
    return _routes == nil ? 0 : [_routes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kRouteCell"];
    
    if(!cell){
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"RouteCell" owner:nil options:nil];
        cell = nib[0];
    }
    Route* route = _routes[indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];
    NSString* start = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[route.startTime intValue]]];
    NSString* end = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[route.endTime intValue]]];
    NSString* schedule = [start stringByAppendingString:@" 到 "];
    schedule = [schedule stringByAppendingString:end];
    cell.schedule.text = schedule;
    cell.age.text = [route.user.age stringByAppendingString:@"岁"];
    cell.destination.text = route.destination;
    if(route.user.avatar.length > 0){
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:route.user.avatar]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Route* route = _routes[indexPath.row];
    RouteDetailViewController* detail = [[RouteDetailViewController alloc] initWithNibName:@"RouteDetailViewController" bundle:nil];
    detail.route = route;
//    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController pushViewController:detail animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
