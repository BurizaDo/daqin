//
//  BXChatListViewController.m
//  Baixing
//
//  Created by neoman on 5/20/14.
//
//

#import "BXChatListViewController.h"
#import "UIImageView+WebCache.h"
#import "MessageViewController.h"
#import "MessageInfo.h"
#import "MessageInfoCell.h"
#import "MessageProvider.h"
#import "ChatSession.h"
#import "ChatUser.h"
#import "GlobalDataManager.h"

@interface BXChatListViewController ()
@property (nonatomic, strong) NSMutableArray        *messageInfoes;

@property (nonatomic, weak) IBOutlet UITableView    *tableView;
@property (nonatomic, assign) BOOL isBlackList;
@end

@implementation BXChatListViewController
- (id)initIfIsBlackList:(BOOL)isBlackList{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isBlackList = isBlackList;
        self.title = _isBlackList ? @"黑名单" : @"私信";
        self.hidesBottomBarWhenPushed = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData)
                                                     name:kNotifcationMessageChange
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData)
                                                     name:kNotificationReloadSessionFromDB
                                                   object:nil];
        [self commonInit];
        
//        if(!_isBlackList){
//            [self setRightBarItemTitle:@"黑名单" select:@selector(blackListClicked:)];
//        }
    }
    
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"私信";
        self.hidesBottomBarWhenPushed = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData)
                                                     name:kNotifcationMessageChange
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData)
                                                     name:kNotificationReloadSessionFromDB
                                                   object:nil];
        [self commonInit];
    }
//    [self setRightBarItemTitle:@"黑名单" select:@selector(blackListClicked:)];
    return self;
}

//- (void)blackListClicked:(UIButton*)sender{
//    BXChatListViewController *blackVC = [[BXChatListViewController alloc] initIfIsBlackList:YES];
//    [self navigationPushViewController:blackVC animated:YES];
//}

- (void)loadDataFromDB{
    self.messageInfoes = [[MessageProvider queryMessageInfoList] mutableCopy];
//    NSArray* blackList = [BlackListUtil getCachedBlackList];
//    NSMutableArray* backupList = [[NSMutableArray alloc] init];
//    if(blackList) {
//        for(BXMessageInfo* info in self.messageInfoes){
//            for(NSString* receiveId in blackList){
//                if([receiveId isEqualToString:info.receiveId]){
//                    [backupList addObject:info];
//                }
//            }
//        }
//        if(_isBlackList){
//            self.messageInfoes = backupList;
//        }else{
//            [self.messageInfoes removeObjectsInArray:backupList];
//        }
//    }

}

- (void)commonInit
{
    [self loadDataFromDB];
    
//    __weak ChatListViewController* weakself = self;
//    
//    if(!_isBlackList){
//        self.tableDataSource.cellAllowDeleteBlock = ^(NSIndexPath *indexPath) {
//            
//            return YES;
//        };
//    }
    
}

- (void)reloadData
{
    [self loadDataFromDB];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![GlobalDataManager sharedInstance].user) {
        [_messageInfoes removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    [self reloadData];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - table selection action 
- (void)openMessageInfo:(MessageInfo *)messageInfo
{
    MessageViewController *messageVC = [[MessageViewController alloc] init];
    messageVC.receiverChatUser = [MessageProvider queryChatUserWithReceiverId:messageInfo.receiveId];
    [ChatSession sharedInstance].receiverUser = messageVC.receiverChatUser;
    [messageVC initData];
    
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageInfo* messageInfo = [self.messageInfoes objectAtIndex:indexPath.row];
    [self openMessageInfo:messageInfo];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageInfoes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgInfoCell"];
    
    if(!cell){
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"MessageInfoCell" owner:nil options:nil];
        cell = nib[0];
    }
    MessageInfo* msg = self.messageInfoes[indexPath.row];
    cell.titleLabel.text = msg.name;
    cell.subTitleLabel.text = msg.content;
    if(msg.badgeCount > 0){
        cell.badgeImageView.hidden = NO;
    }else{
        cell.badgeImageView.hidden = YES;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    cell.dateLabel.text = [formatter stringFromDate:msg.timeStamp];

    cell.iconView.layer.cornerRadius = cell.iconView.bounds.size.height / 2;
    cell.iconView.layer.masksToBounds = YES;
    [cell.iconView setImageWithURL:[NSURL URLWithString:msg.iconUrl]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    id obj = [_messageInfoes objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MessageInfo* messageInfo = obj;
        [MessageProvider removeChatPeerWithReceiverId:messageInfo.receiveId];        
    });


    [_messageInfoes removeObjectAtIndex:indexPath.row];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
}

@end
