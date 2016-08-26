//
//  LLEMChatsViewController.m
//  Olla
//
//  Created by Pat on 15/3/19.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//
#import "LLEMChatsViewController.h"
#import "EMSearchBar.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "LLEMIMViewController.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "LLEMChatsTableViewCell.h"
#import "LLEMUserDAO.h"
#import "LLEMChatsSearchUtil.h"
#import "LLSupplyProfileService.h"
#import "PureLayout.h"
#import "GCDObjC.h"
#import "AppDelegate.h"
#import "LLEMChatsDebugViewController.h"
#import "LLEaseModUtil.h"

@interface LLEMChatsViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, IChatManagerDelegate, LLEMUserDAODelegate> {
    GCDQueue *_refreshQueue;
    LLEMUserDAO *_userDAO;
    LLSupplyProfileService *_profileService;
}

@property (strong, nonatomic) NSMutableArray        *dataSource;
@property (strong, nonatomic) NSMutableArray        *converations;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) UISearchBar           *searchBar;
@property (nonatomic, strong) UIView                *networkStateView;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (strong, nonatomic) UIView *quickHelpView;

@end

@implementation LLEMChatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _refreshQueue = [[GCDQueue alloc] initSerial];
        _userDAO = [[LLEMUserDAO alloc] init];
        _userDAO.delegate = self;
        _profileService = [[LLSupplyProfileService alloc] init];
        _dataSource = [NSMutableArray array];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB_DECIMAL(247, 247, 247);
    
    
    _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    if ([_searchBar respondsToSelector:@selector(setSearchBarStyle:)]) {
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        [_searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]]];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = RGB_DECIMAL(247, 247, 247);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.tableHeaderView = _searchBar;
    
    [self.view addSubview:_tableView];
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(68, 0, 0, 0)];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(handleRefresh:)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    _tableView.header = header;

    _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 44)];
    _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
    imageView.image = [UIImage imageNamed:@"messageSendFail"];
    [_networkStateView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"network.disconnection", @"小明，你妈喊你回家...");
    [_networkStateView addSubview:label];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 32, 32);
    _indicatorView.center = CGPointMake(self.view.width / 2, self.view.height / 2 - 44);
    _indicatorView.hidesWhenStopped = YES;
    [self.view addSubview:self.indicatorView];
    
//    EMSearchDisplayController
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self) weakSelf = self;
    [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        static NSString *CellIdentifier = @"ChatListCell";
        LLEMChatsTableViewCell *cell = (LLEMChatsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[LLEMChatsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.chatsItem = weakSelf.searchController.resultsSource[indexPath.row];
        
        return cell;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return 64;
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [weakSelf.searchController.searchBar endEditing:YES];
        
        LLEMChatsItem *chatsItem = weakSelf.searchController.resultsSource[indexPath.row];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[chatsItem.userInfo dictionaryRepresentation]];
        [dict setValue:@1 forKey:@"flag"];

        [weakSelf openURL:[NSURL URLWithString:@"lbslm:///root/plaza/chats/im" queryValue:dict] animated:YES];
    }];

    // 旧的quick tutor 入口, 如需使用, 去掉注释即可
   // [self initViewForSection];
}

- (void)initViewForSection
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 53)];
    view.backgroundColor = [UIColor whiteColor];
    UIButton *toQuickHelpBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 53)];
    [toQuickHelpBarButton addTarget:self action:@selector(jumpToQuickHelpBar) forControlEvents:UIControlEventTouchUpInside];
    UIImage *buttonImage = [UIImage imageNamed:@"quick_help_entrance2.jpg"];
    [toQuickHelpBarButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [view addSubview:toQuickHelpBarButton];
    self.quickHelpView = view;
}



- (void)gotoProfilePageWithUserInfo:(LLSimpleUser *)userInfo
{
    
    if ([[self.url queryValue][@"flag"] intValue]==1) {
        //TODO:如果可以从一个内页进入IM，这里就要改了 ==》“olla:///root/tab/im"
        
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[userInfo dictionaryRepresentation]];
        [query setValue:@(0) forKey:@"flag"];
        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
        
        
    }else if([[self.url queryValue][@"flag"] intValue]==0){
        //从IM回退到user-center
        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByReplacingOccurrencesOfString:@"im" withString:@""] queryValue:@{@"flag":@1}] animated:YES];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBarHidden = NO;
    
    [self registerNotifications];
    __block __weak typeof(self) weakSelf = self;
    
    if ([[LLEaseModUtil sharedUtil] isLoggedIn])
    {
        [self removeEmptyConversationsFromDB];
        [self refreshDataSource];
        self.tableView.tableHeaderView = weakSelf.searchBar;
        self.view.userInteractionEnabled = YES;
        [self hideHud];
    }
    else
    {
        if (self.view.userInteractionEnabled)
        {
            self.view.userInteractionEnabled = NO;
            [self showHudInView:weakSelf.view hint:@"卖力加载中..."];
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed)
            {
                if (succeed)
                {
                    [weakSelf removeEmptyConversationsFromDB];
                    [weakSelf refreshDataSource];
                    weakSelf.tableView.tableHeaderView = weakSelf.searchBar;
                }
                else
                {
                    weakSelf.tableView.tableHeaderView = weakSelf.networkStateView;
                }
                [weakSelf hideHud];
                weakSelf.view.userInteractionEnabled = YES;
            }];
        }
        
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}
- (IBAction)back:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}


#pragma mark - private

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

#pragma mark - TableViewDelegate & TableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"chatListCell";
    LLEMChatsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[LLEMChatsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    cell.chatsItem = [self.dataSource objectAtIndex:indexPath.row];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

    
    LLEMChatsItem *chatsItem = self.dataSource[indexPath.row];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[chatsItem.userInfo dictionaryRepresentation]];
    [dict setValue:@1 forKey:@"flag"];
    [self openURL:[self.url URLByAppendingPathComponent:@"im" queryValue:dict] animated:YES];
//    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
//    
//    ChatViewController *chatController;
//    NSString *title = conversation.chatter;
//    if (conversation.isGroup) {
//        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
//        for (EMGroup *group in groupArray) {
//            if ([group.groupId isEqualToString:conversation.chatter]) {
//                title = group.groupSubject;
//                break;
//            }
//        }
//    }
//    
//    NSString *chatter = conversation.chatter;
//    chatController = [[ChatViewController alloc] initWithChatter:chatter isGroup:conversation.isGroup];
//    chatController.title = title;
//    [self.navigationController pushViewController:chatController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LLEMChatsItem *chatsItem = self.dataSource[indexPath.row];
        EMConversation *converation = chatsItem.conversation;
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:NO];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    return self.quickHelpView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//    return 53.f;
//}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{

    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    [[LLEMChatsSearchUtil sharedUtil] searchText:searchText dataSource:self.dataSource resultBlock:^(NSArray *results) {
        [self.searchController.resultsSource removeAllObjects];
        [self.searchController.resultsSource addObjectsFromArray:results];
        [self.searchController.searchResultsTableView reloadData];
    }];
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

//刷新消息列表
- (void)handleRefresh:(id)sender
{
    __block __weak typeof(self) weakSelf = self;
    if ([[LLEaseModUtil sharedUtil] isLoggedIn]) {
        [self removeEmptyConversationsFromDB];
        [self refreshUserInfos];
        [self refreshDataSource];
    } else {
        self.view.userInteractionEnabled = NO;
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        [self showHudInView:weakSelf.view hint:@"连接中..."];
        [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed) {
            if (succeed) {
                [weakSelf removeEmptyConversationsFromDB];
                [weakSelf refreshUserInfos];
                [weakSelf refreshDataSource];
                weakSelf.tableView.tableHeaderView = weakSelf.searchBar;
                weakSelf.navigationItem.title = @"我的消息";
            } else {
                weakSelf.tableView.tableHeaderView = weakSelf.networkStateView;
                weakSelf.navigationItem.title = @"未连接";
            }
            [weakSelf hideHud];
            weakSelf.view.userInteractionEnabled = YES;
        }];
    }
    
    
    [self.tableView.header endRefreshing];
}

- (void)refreshUserInfos {
    
    __block __weak typeof(self) weakSelf = self;
    [_refreshQueue queueBlock:^{
        NSMutableArray *fetchUids = [NSMutableArray array];
        for (LLEMChatsItem *chatItem in weakSelf.dataSource) {
            if (chatItem.userInfo.uid.length > 0) {
                [fetchUids addObject:chatItem.userInfo.uid];
            }
        }
        if (fetchUids.count > 0) {
            [_userDAO getUsersWithIds:fetchUids];
        }
    }];
}

#pragma mark - message receipt

- (void)didReceiveHasReadResponse:(EMReceipt *)receipt {
    [self.tableView reloadData];
}

- (void)didReceiveHasDeliveredResponse:(EMReceipt *)receipt {
    [self.tableView reloadData];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - public

-(void)refreshDataSource
{
    __block __weak typeof(self) weakSelf = self;
    [_refreshQueue queueBlock:^{
        [[GCDQueue mainQueue] queueBlock:^{
            if (weakSelf.dataSource.count == 0) {
                [weakSelf.indicatorView startAnimating];
            }
        }];
        
        NSMutableArray *converations = [weakSelf loadDataSource];
        NSMutableArray *chatsItems = [NSMutableArray array];
        NSMutableArray *fetchUids = [NSMutableArray array];
        for (EMConversation *conversation in converations)
        {
            NSString *uid = conversation.chatter;
            if (uid.length == 0)
            {
                continue;
            }
            LLUser *friendInfo = [_userDAO userInfoWithUID:uid];
            if (friendInfo)
            {
                // 排除重复处理
                BOOL exist = NO;
                for (LLEMChatsItem *existItem in chatsItems)
                {
                    if ([existItem.userInfo.uid isEqualToString:friendInfo.uid] || [existItem.conversation.chatter isEqualToString:conversation.chatter]) {
                        exist = YES;
                        break;
                    }
                }
                if (!exist) {
                    LLEMChatsItem *chatsItem = [[LLEMChatsItem alloc] init];
                    chatsItem.userInfo = friendInfo;
                    chatsItem.conversation = conversation;
                    [chatsItems addObject:chatsItem];
                }
            }
            else
            {
                [fetchUids addObject:uid];
            }
            
        }
        
        if (fetchUids.count > 0) {
            [_userDAO getUsersWithIds:fetchUids];
        }
        
        [[GCDQueue mainQueue] queueBlock:^{
            if (weakSelf.indicatorView.isAnimating) {
                [weakSelf.indicatorView stopAnimating];
            }
            weakSelf.dataSource = chatsItems;
            [weakSelf.tableView reloadData];
        }];
        
    }];
    
    
}

- (void)getUserInfoFinish {
    [self refreshDataSource];
}

- (void)getUserInfoFail {
    
}

- (void)isConnect:(BOOL)isConnect{
    if (!_tableView) {
        return;
    }
    if (!isConnect) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = _searchBar;
    }
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (!_tableView) {
        return;
    }
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    } else {
        _tableView.tableHeaderView = _searchBar;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(@"%@", NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(@"%@", NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
    [self refreshDataSource];
}

@end
