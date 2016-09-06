//
//  LLHotShareViewController.m
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLTopicShareViewController.h"
#import "LLHomeShareViewCell.h"
#import "LLLoadingView.h"

@interface LLTopicShareViewController ()
{
        LLUserService *userService;
        LLShareDataSource *shareDataSource;
}

@property (strong, nonatomic) NSMutableArray *shareDataSource;
@property (strong, nonatomic) LLLoadingView *loadingView;
@property (strong, nonatomic) NSString *topic;

@end

@implementation LLTopicShareViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _shareDataSource = [NSMutableArray array];
        
        shareDataSource = [[LLShareDataSource alloc] init];
        shareDataSource.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBarButtonItem];
    self.topic = self.params;
    userService = [[LLUserService alloc] init];
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh:)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.header = header;
    self.title = self.topic;
    // 加载更多
    self.loadingView = [[LLLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.loadingView.statusLabel.font = [UIFont systemFontOfSize:11.f];
    self.loadingView.statusLabel.textColor = [UIColor lightGrayColor];
    self.loadingView.size = 20;
    self.tableView.tableFooterView = self.loadingView;
    
    // 获取缓存数据
    [self loadCacheData];
    
    // 开始刷新
    [self.tableView.header beginRefreshing];
}


- (IBAction)backAction:(id)sender
{
    if ([[self.url absoluteString] hasPrefix:@"present:"])
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupBarButtonItem
{
    [self.navigationController setNavigationBarHidden:NO];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [backButton setImage:[UIImage imageNamed:@"navigation_back_arrow_new"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(id)sender {
    
    if (!userService)
    {
        userService = [[LLUserService alloc] init];
    }
    [self loadData];
}

- (void)loadCacheData
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"pageId"] = @(1);
    params[@"size"] = @(20);
    params[@"topic"] = self.topic;
    
    NSArray *cacheArray = [[LLAPICache sharedCache] cacheArrayWithURL:TM_API_Topic_Share_List
                                                               params:params
                                                                class:[LLShare class]
                                                              orderBy:@"posttime DESC" limit:20];
    if (cacheArray.count > 0)
    {
        [self.shareDataSource removeAllObjects];
        [self.shareDataSource addObjectsFromArray:cacheArray];
        [self.tableView reloadData];
    }
}

- (void)loadData
{
    
    self.loadingView.page = 1;
    
    __weak __block typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager]
     GETListWithURL:TM_API_Topic_Share_List
     parameters:@{
                  @"topic":self.topic,
                  @"pageId":@(1),
                  @"size":@(20)
                  }
     modelType:[LLShare class]
     needCache:YES
     success:^(NSArray *datas , BOOL hasNext)
     {
         
         __strong __typeof(self)strongSelf = weakSelf;
         strongSelf.loadingView.hasNext = hasNext;
         if (hasNext)
         {
             self.loadingView.page += 1;
         }
         
         // 未过滤时用
//          [strongSelf.shareDataSource removeAllObjects];
//          [strongSelf.shareDataSource addObjectsFromArray:datas];
         // 做过滤
         [strongSelf.shareDataSource removeAllObjects];
         strongSelf.shareDataSource = [self dataFilter:datas];
         for (int i = 0; i < [ datas count]; i++)
         {
             LLShare *share = [datas objectAtIndex:i];
             
         }
         [strongSelf.tableView reloadData];
         [strongSelf.tableView.header endRefreshing];
     }
     failure:^(NSError *error)
     {
         [weakSelf.tableView.header endRefreshing];
     }];
    
}

- (NSMutableArray *)dataFilter:(id)data
{
    NSMutableArray *filter = [NSMutableArray array];
    [filter removeAllObjects];
    
    for (LLShare *share in data)
    {
        [filter addObject:share];
    }
    
    return filter;
}

- (void)loadMoreData
{
    
    int page = self.loadingView.page;
    int size = self.loadingView.size;
    NSLog(@"page : %d", page);
    
    [self.loadingView startLoading];
    
    __weak __block typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager]
     GETListWithURL:TM_API_Topic_Share_List
     parameters:@{
                  @"topic":self.topic,
                  @"pageId":@(page),
                  @"size":@(size)
                  }
     modelType:[LLShare class]
     success:^(NSArray *datas , BOOL hasNext){
         
         __strong __typeof(self)strongSelf = weakSelf;
         strongSelf.loadingView.hasNext = hasNext;
         if (hasNext) {
             strongSelf.loadingView.page += 1;
         }
         // 未过滤时用
//                  [strongSelf.shareDataSource addObjectsFromArray:datas];
         // 做过滤
         [strongSelf.shareDataSource addObjectsFromArray:[self dataFilter:datas]];
         // *****
         [strongSelf.tableView reloadData];
         
         [strongSelf.loadingView stopLoading];
     } failure:^(NSError *error){
         
         [weakSelf.loadingView stopLoading];
     }];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shareDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    {
        LLHomeShareViewCell *shareCell = (LLHomeShareViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LLHomeShareViewCell"];
        if (!shareCell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLHomeShareViewCell" owner:self options:nil];
            shareCell = (LLHomeShareViewCell *)[nib objectAtIndex:0];
        }
        shareCell.displayLocation = YES;
        shareCell.dataItem = self.shareDataSource[indexPath.row];
        cell = shareCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    {
        LLHomeShareViewCell *shareCell =  [[LLHomeShareViewCell alloc] init];
        shareCell.displayLocation = YES;
        height = [shareCell shareCellHeight:self.shareDataSource[indexPath.row]];
    }
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

        if ((indexPath.row == self.shareDataSource.count - 1) && self.loadingView.hasNext)
        {
            [self loadMoreData];
        }
    
}


#pragma mark - Router
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    
    if ([eventName isEqualToString:LLShareTextURLClickEvent])
    {  // 点击网址
        NSURL *url = userInfo[@"url"];
        
        if (url) {
            if ([url.absoluteString hasPrefix:@"mailto"]) {
                [[UIApplication sharedApplication] openURL:url];
            } else {
                SVWebViewController *webVC = [[SVWebViewController alloc] initWithURL:url];
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
    }
    else if ([eventName isEqualToString:LLShareTextPhoneNumberClickEvent])
    {  // 电话号码
        NSString *phoneNumber = userInfo[@"phoneNumber"];
        PSTAlertController *alertVC = [PSTAlertController alertControllerWithTitle:phoneNumber message:nil preferredStyle:PSTAlertControllerStyleAlert];
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Copy" handler:^(PSTAlertAction *action) {
            [[UIPasteboard generalPasteboard] setString:phoneNumber];
            //            [self showHint:@"Copy to pasteboard"];
        }]];
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Call" handler:^(PSTAlertAction *action) {
            NSString *phoneStr = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneStr]];
            [[UIApplication sharedApplication] openURL:url];
        }]];
        
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Cancel" style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
            
        }]];
        
        [alertVC showWithSender:nil controller:self animated:YES completion:nil];
    }
    else if ([eventName isEqualToString:LLMyCenterShareLikeClickEvent])
    {  // 点赞
        BOOL isGood = [[userInfo objectForKey:@"isGood"] boolValue];
        if (isGood)
        {
            // 发送取消点赞请求
            [self doUnlike:[userInfo objectForKey:@"dataItem"] isShare:[[userInfo objectForKey:@"isShare"] boolValue]];
        } else {
            // 发送点赞请求
            [self doLike:[userInfo objectForKey:@"dataItem"] isShare:[[userInfo objectForKey:@"isShare"] boolValue]];
        }
        
    }
    else if ([eventName isEqualToString:LLMyCenterFocusButtonClickEvent])
    {  // 点赞
        // [self focusShare:[userInfo objectForKey:@"dataItem"]];
        
    }
    else if ([eventName isEqualToString:LLMyCenterShareCommentClickEvent])
    {  // 点击评论
        // 先判断是否填写资料
        LLShare *dataItem = [userInfo objectForKey:@"dataItem"];
        [self openURL:[NSURL URLWithString:@"present:///root/share-detail" ] params:dataItem animated:YES];
    } else if ([eventName isEqualToString:LLMyCenterShareBackgroundButtonClickEvent])
    {
        
        // 跳到share详情
        LLShare *dataItem = [userInfo objectForKey:@"share"];
        [self openURL:[NSURL URLWithString:@"present:///root/share-detail" ] params:dataItem animated:YES];
    }
    else if ([eventName isEqualToString:LLMyCenterShareTapGestureClickEvent])
    {
        // 先判断是否填写资料
        LLShare *dataItem = [userInfo objectForKey:@"share"];
        [self openURL:[NSURL URLWithString:@"present:///root/share-detail" ] params:dataItem animated:YES];
        //     }
    }
    else if ([eventName isEqualToString:LLMyCenterShareShareButtonClickEvent])
    {  // 分享
        
        LLShare *dataItem = [userInfo objectForKey:@"share"];
        //        if (dataItem.bar) {
        //            [self shareWithPost:dataItem];
        //        } else {
        //     [self shareWithShare:dataItem];
        //  }
    }
    else if ([eventName isEqualToString:LLMyCenterShareAvatarButtonClickEvent])
    {
        LLUser *user = [userInfo objectForKey:@"user"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
        [dict setValue:@1 forKey:@"flag"];
        [self openURL:[self.url URLByAppendingPathComponent:@"im" queryValue:dict] animated:YES];
        
    }
    else if ([eventName isEqualToString:LLMyCenterShareRewardButtonClickEvent])
    {
        
        LLShare *dataItem = [userInfo objectForKey:@"share"];
        if ([dataItem.user.uid isEqualToString:[userService getMe].uid]) {
            [UIAlertView showWithTitle:nil message:@"You cannot tip yourself." cancelButtonTitle:nil otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
                
                if (tapIndex == 0) {//OK
                    
                    return ;
                }
                
            }];
        } else {
            //            [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"reward"]] params:@{@"post":dataItem} animated:YES];
        }
    }
    else if ([eventName isEqualToString:LLMyCenterOptButtonClickEvent])
    {
        
        LLShare *dataItem = [userInfo objectForKey:@"dataItem"];
        [self opt:dataItem];
        
    }
    
}

#pragma mark - Like & Unlike
- (void)doLike:(id)sender isShare:(BOOL)isShare{
    if (isShare) {
        LLShare *share = (LLShare *)sender;
        
        //        __weak typeof(self) weakSelf = self;
        [[LLHTTPRequestOperationManager shareManager]
         GETWithURL:Olla_API_Share_Like
         parameters:@{@"shareId":share.shareId}
         success:^(id datas , BOOL hasNext){
             
             
         } failure:^(NSError *error){
             
             //[JDStatusBarNotification showWithStatus:@"like failed" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         }];
    } else {
        LLShare *post = (LLShare *)sender;
        
        //        __weak typeof(self) weakSelf = self;
        [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Groupbar_Post_Like parameters:@{@"shareId":post.shareId} success:^(id datas , BOOL hasNext){
            
            
        } failure:^(NSError *error){
        }];
    }
}

- (void)doUnlike:(id)sender isShare:(BOOL)isShare {
    
    LLShare *share = (LLShare *)sender;
    
    // 修改写操作 [LLHTTPRequestOperationManager shareManager] => [LLHTTPWriteOperationManager shareWriteManager]
    [[LLHTTPWriteOperationManager shareWriteManager] GETWithURL:Olla_API_Share_Unlike parameters:@{@"shareId":share.shareId} success:^(id datas , BOOL hasNext){
        
    } failure:^(NSError *error){
        
    }];
    
}

#pragma mark - Notification
// 收到新评论{"cmd":"news","type":"comment","data":uid,shareId,commentId}
- (void)receiveComment:(NSNotification *)notification{
    
    //    NSAssert([notification.userInfo isDictionary], @"");
    [self.view setBackgroundColor:[UIColor clearColor]];// 强制loadView
    [shareDataSource loadUnreadNotifyMessages];
}


- (void)updateNewComments{
    
    NSInteger commentCounts = [self.navigationController.tabBarItem.badgeValue integerValue];
    
    // 减去email和birth的数目
    if (![[[LLPreference shareInstance] valueForKey:@"isEmail"] boolValue]) {
        // 减去
        if (commentCounts > 0) {
            commentCounts -= 1;
        }
    }
    
    if (![[[LLPreference shareInstance] valueForKey:@"isBirth"] boolValue]) {
        // 减去
        if (commentCounts > 0) {
            commentCounts -= 1;
        }
    }
}



// 覆盖掉refreshview
- (void)showMessageNotificationWithAvatar:(NSString *)avatar messageCount:(NSInteger)count{
    
    if (![avatar isString] || [avatar length]==0) {
        DDLogError(@"收到新评论通知，但是avatar信息不对：%@", avatar);
        return;
    }
    
    if (count <= 0) {
        return;
    }
    
    NSString *promptMessage = [NSString stringWithFormat:@"%li comment",(long)count];
    if (count > 1) {
        promptMessage = [promptMessage stringByAppendingString:@"s"];
    }
    
    [self.tableView reloadData];
    
}


- (void) opt:(LLShare *)share
{
    [UIActionSheet showInView:[self.presentedViewController view]
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[
                                @"删除",@"关小黑屋",
                                @"置顶",@"取消置顶",
                                @"重置密码",@"和他/她聊天"]
                     tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex)
     {
         
         if (0==tapIndex)
         {
             [self delShare:share];
         }
         else if(1==tapIndex)
         {
             [self dark:share.user.uid];
         }
         else if(2==tapIndex)
         {
             [self moveTop:share];
         }
         else if(3==tapIndex)
         {
             [self reMoveTop:share];
         }
         else if(4==tapIndex)
         {
             [self resetPasswd:share.user.uid];
         }
         else if(5==tapIndex)
         {
             NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[share.user dictionaryRepresentation]];
             [dict setValue:@1 forKey:@"flag"];
             [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"im"] queryValue:dict] animated:YES];
             //             [self openURL:[NSURL URLWithString:@"lbslm:///root/plaza/chats/im" queryValue:dict] animated:YES];
         }
         
         
     }];
}

- (void) resetPasswd : (NSString *)uid
{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:TM_API_Edit_Password
     parameters:@{@"uid": [NSNumber numberWithLong:[uid longLongValue]]}
     success:^(id datas , BOOL hasNext)
     {
         [JDStatusBarNotification showWithStatus:@"已重置密码" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     }
     failure:^(NSError *error)
     {
         
         [JDStatusBarNotification showWithStatus:@"重置失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
     }];
}

- (void) moveTop : (LLShare *)share
{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:LBSLM_API_Share_Focus
     parameters:@{@"shareId":share.shareId}
     success:^(id datas , BOOL hasNext)
     {
         [JDStatusBarNotification showWithStatus:@"置顶成功" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     }
     failure:^(NSError *error)
     {
         
         [JDStatusBarNotification showWithStatus:@"置顶失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
     }];
}

- (void) reMoveTop : (LLShare *)share
{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:LBSLM_API_Share_UnFocus
     parameters:@{@"shareId":share.shareId}
     success:^(id datas , BOOL hasNext)
     {
         [JDStatusBarNotification showWithStatus:@"置顶移除" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     }
     failure:^(NSError *error)
     {
         
         [JDStatusBarNotification showWithStatus:@"置顶移除失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
     }];
}

- (void) dark : (NSString *)uid
{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:TM_API_Dark_User
     parameters:@{@"uid": [NSNumber numberWithLong:[uid longLongValue]]}
     success:^(id datas , BOOL hasNext)
     {
         [JDStatusBarNotification showWithStatus:@"已成功关小黑屋" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     }
     failure:^(NSError *error)
     {
         
         [JDStatusBarNotification showWithStatus:@"关小黑屋失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
     }];
}

- (void) delShare : (LLShare *)share
{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:LBSLM_API_Share_Delete
     parameters:@{@"shareId":share.shareId}
     success:^(id datas , BOOL hasNext)
     {
         [JDStatusBarNotification showWithStatus:@"删除成功" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         [self refresh:nil];
         
     }
     failure:^(NSError *error)
     {
         
         [JDStatusBarNotification showWithStatus:@"删除失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
     }];
}


@end
