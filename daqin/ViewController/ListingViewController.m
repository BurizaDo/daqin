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
#import "Uploader.h"
#import "GlobalDataManager.h"
#import "ViewUtil.h"

@interface ListingViewController ()
@property (nonatomic, strong) NSMutableArray* routes;
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
    if(_isMyListing){
        [ListingProvider getUserListing:[GlobalDataManager sharedInstance].user.userId from:from size:30 onSuccess:^(NSArray *areas) {
            if(from == 0){
                _routes = [NSMutableArray arrayWithArray:areas];
            }else{
                [_routes addObjectsFromArray:areas];
            }
            [self.tableView reloadData];
            if(stopAnimation){
                [self.tableView.pullToRefreshView stopAnimating];
                [self.tableView.infiniteScrollingView stopAnimating];
            }
            
        } onFailure:^(Error *error) {
            
        }];
    }else{
        [ListingProvider getAllListingFrom:from size:30 onSuccess:^(NSArray *areas) {
            if(from == 0){
                _routes = [NSMutableArray arrayWithArray:areas];
            }else{
                [_routes addObjectsFromArray:areas];
            }

            [self.tableView reloadData];
            if(stopAnimation){
                [self.tableView.pullToRefreshView stopAnimating];
                [self.tableView.infiniteScrollingView stopAnimating];
            }

        } onFailure:^(Error *error) {
            
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData:NO from:0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if(_isMyListing){
        self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(backAction)];
    }
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
        if(wlv.routes.count % 30 == 0){
            [wlv loadData:YES from:wlv.routes.count];
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
    return _routes == nil ? 0 : [_routes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
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
    [formatter setDateFormat:@"MM/dd"];
    NSString* start = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[route.startTime intValue]]];
    NSString* end = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[route.endTime intValue]]];
    NSString* schedule = [start stringByAppendingString:@" 至 "];
    schedule = [schedule stringByAppendingString:end];
    cell.schedule.text = schedule;
    cell.age.text = [route.user.age stringByAppendingString:@"岁"];
    cell.age.layer.cornerRadius = cell.age.bounds.size.height/2;
    cell.destination.text = route.destination;
    cell.name.text = route.user.name;
//    cell.signature.text = route.user.signature;
    cell.signature.text = route.description;
    
    UIColor* colorF = [UIColor colorWithRed:255/255.0 green:172/255.0 blue:184/255.0 alpha:1];
    UIColor* colorM = [UIColor colorWithRed:172/255.0 green:215/255.0 blue:255/255.0 alpha:1];
    if([route.user.gender isEqualToString:@"男"]){
        cell.age.backgroundColor = colorM;
    }else{
        cell.age.backgroundColor = colorF;
    }


    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize = [cell.name.text sizeWithFont:cell.name.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:cell.name.lineBreakMode];
    cell.name.frame = CGRectMake(cell.name.frame.origin.x, cell.name.frame.origin.y, expectedLabelSize.width, expectedLabelSize.height);
    
    cell.age.frame = CGRectMake(cell.name.frame.origin.x + cell.name.frame.size.width + 8, cell.age.frame.origin.y, cell.age.frame.size.width, cell.age.frame.size.height);
    
    if(route.user.avatar.length > 0){
        [cell.avatar.layer setCornerRadius:(CGRectGetHeight(cell.avatar.bounds))/2];
        cell.avatar.clipsToBounds = YES;
//        cell.avatar.layer.borderWidth = 2.0;
//        cell.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:route.user.avatar]];
    }
    if(indexPath.row % 2 != 0){
        cell.backgroundColor = [UIColor colorWithRed:0xf8/255.0 green:0xf8/255.0 blue:0xf8/255.0 alpha:1];
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_routes removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];

//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
