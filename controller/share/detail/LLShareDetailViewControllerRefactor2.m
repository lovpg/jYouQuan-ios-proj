//
//  LLShareDetailViewControllerRefactor2.m
//  Olla
//
//  Created by Charles on 15/7/24.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLShareDetailViewControllerRefactor2.h"
#import "LLLike.h"
#import "LLComment.h"
#import "LLShareDetailTableViewCellRefactor.h"
#import "LLBottomActionSheet.h"
#import "LLUserDAO.h"
#import "LLThirdCollection.h"

@interface LLShareDetailViewControllerRefactor2 ()  {
    
    LLUserService *userService;
//    LLShareViewController *shareVC;
    __weak IBOutlet UITableView *myTableView;
}
@property (weak, nonatomic) IBOutlet UIButton *reportButton;

@property (nonatomic, strong) NSMutableArray *likeList;
@property (nonatomic, strong) LLShareDetailTableViewCellRefactor *shareHeaderCell;

@end

@implementation LLShareDetailViewControllerRefactor2


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        UIImage *aimage = [UIImage imageNamed:@"navigation_back_arrow_new"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(backAction:)];
        [self.navigationItem setLeftBarButtonItem:leftItem animated:YES];
        
        UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [moreButton setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
        [self.navigationItem setRightBarButtonItem:moreItem];
        
    }
    return self;
}
- (IBAction)backAction:(id)sender
{
    //    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender
{
    [UIActionSheet showInView:[self.presentedViewController view]
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[
                                @"举报",@"删除"]
                     tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex)
     {
         
         if (0==tapIndex)
         {
             [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_report
                                                           parameters:@{@"shareId":self.share.shareId}
                                                              success:^(id datas, BOOL hasNext)
              {
                  [UIAlertView showWithTitle:nil
                                     message:@"已举报，等待管理员审核."
                           cancelButtonTitle:nil
                           otherButtonTitles:@[@"确定"]
                                    tapBlock:^(UIAlertView *alertView,NSInteger tapIndex)
                   {
                       
                       if (tapIndex == 0)
                       {
                           return ;
                       }
                       
                   }];
              }
                                                              failure:^(NSError *error)
              {
                  NSString *errorMsg = [error.userInfo stringForKey:@"message"];
                  if (errorMsg.length == 0) {
                      errorMsg = error.localizedDescription;
                  }
                  
                  [UIAlertView showWithTitle:nil
                                     message:errorMsg
                           cancelButtonTitle:nil
                           otherButtonTitles:@[@"确定"]
                                    tapBlock:^(UIAlertView *alertView,NSInteger tapIndex)
                   {
                       
                       if (tapIndex == 0)
                       {
                           return ;
                       }
                       
                   }];
              }];
         }
         else if (1==tapIndex)
         {
             [self doDelete:sender];
         }
         
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    if ([lastPlayRecordButton.audioPlayer isPlaying]) {
//        [lastPlayRecordButton stop];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   // UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:self.drButton];
    userService = [[LLUserService alloc] init];
    
    // 导航栏左按钮更换图标 navigation_back_arrow_new
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back_arrow_new"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    myTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.backgroundColor = RGB_DECIMAL(247, 247, 247);
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTableView.tableFooterView = [[UIView alloc] init];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.tableView = myTableView;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    // 刷新
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [myTableView addSubview:self.refreshControl];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh:)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    myTableView.header = header;
    
    // 加载
    self.loadingView = [[LLLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.loadingView.statusLabel.font = [UIFont systemFontOfSize:11.f];
    self.loadingView.statusLabel.textColor = [UIColor lightGrayColor];
    [AppDelegate storyBoradAutoLay:self.loadingView];
    myTableView.tableFooterView = self.loadingView;
    self.share = self.params;
    [self.dataItemDataSource removeAllObjects];
    [self.dataItemDataSource addObject:self.share];
   // [myTableView reloadData];
    
//    if ( ![[[userService getMe] uid] isEqualToString:self.share.user.uid] )
//    {
//        self.drButton.hidden = YES;
//        self.reportButton.hidden = NO;
//    }
//    else
//    {
//        self.drButton.hidden = NO;
//        self.reportButton.hidden = YES;
//    }
    
   [myTableView.header beginRefreshing];
    
    
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
     //   [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)report:(id)sender
{
    [self routerEventWithName:LLShareDetailReportButtonClick userInfo:@{@"report":@""}];
}

#pragma mark - Load, Refresh & Load more data
- (void)loadData {
    
    [super loadData];

    NSAssert(self.share.shareId != nil, @"shareId cannot be nil");
    
//    [self.refreshControl beginRefreshing];
//    [self showHudInView:self.view hint:nil];
  //  [myTableView.header beginRefreshing];
    
    __weak __block typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Share_Detail
                                                  parameters:@{@"shareId":self.share.shareId}
        success:^(id datas, BOOL hasNext)
     {
        //        [weakSelf.dataSource addObject:self.share];
        // share detail 数据源
        [weakSelf.dataItemDataSource removeAllObjects];
         weakSelf.share.goodCount = [[datas objectForKey:@"goodCount"] intValue];
         weakSelf.share.commentCount = [[datas objectForKey:@"commentCount"] intValue];
         weakSelf.share.top =  [[datas objectForKey:@"top"] boolValue];
        [weakSelf.dataItemDataSource addObject:weakSelf.share];
        
        NSMutableArray *likeArr = [NSMutableArray array];
        for (NSDictionary *dic in [datas objectForKey:@"goodList"]) {
            LLLike *like = [[LLLike alloc] init];
            
            like.uid = [dic objectForKey:@"uid"];
            like.avatar = [dic objectForKey:@"avatar"];
            like.sign = [dic objectForKey:@"sign"];
            like.voice = [dic objectForKey:@"voice"];
            like.distanceText = [dic objectForKey:@"distanceText"];
            like.gender = [dic objectForKey:@"gender"];
            like.goodCount = [dic objectForKey:@"goodCount"];
            like.location = [dic objectForKey:@"location"];
            like.nickname = [dic objectForKey:@"nickname"];
            
            [userService get:[dic objectForKey:@"uid"]
                     success:^(LLUser *user)
            {
             
                    LLSimpleUser *su = [[LLSimpleUser alloc] init];
                    su.uid = user.uid;
                    su.userName = user.userName;
                    su.avatar = user.avatar;
                    su.nickname = user.nickname;
                    su.gender = user.gender;
                    su.region = user.region;
                    like.user = su;
            }
            fail:^(NSError *error) {
                
            }];
            
            [likeArr addObject:like];
        }
        weakSelf.likeList = [likeArr mutableCopy];
        
        if (weakSelf.likeList.count != 0) {
            [weakSelf.likeListDataSource removeAllObjects];
            weakSelf.likeListDataSource = [weakSelf.likeList mutableCopy];
            
//            LLShare *share = weakSelf.dataItemDataSource[0];
//            share.goodCount = (int)weakSelf.likeListDataSource.count;
        }
        
        // 存储点赞人的信息
        for (NSDictionary *dic in [datas objectForKey:@"goodList"]) {
            LLSimpleUser *simpleUser = [[LLSimpleUser alloc] init];
            
            simpleUser.uid = [dic objectForKey:@"uid"];
            simpleUser.avatar = [dic objectForKey:@"avatar"];
            simpleUser.sign = [dic objectForKey:@"sign"];
            simpleUser.voice = [dic objectForKey:@"voice"];
            simpleUser.distanceText = [dic objectForKey:@"distanceText"];
            simpleUser.gender = [dic objectForKey:@"gender"];
            simpleUser.region = [dic objectForKey:@"region"];
            simpleUser.location = [dic objectForKey:@"location"];
            simpleUser.nickname = [dic objectForKey:@"nickname"];
            simpleUser.sign = [dic objectForKey:@"sign"];
            
            [weakSelf.likeUsersInfos addObject:simpleUser];
        }
               int size = self.loadingView.size;
        
        NSDictionary *parameters = @{@"shareId":weakSelf.share.shareId, @"pageId":@(1), @"size":@(size)};
        
        [[LLHTTPRequestOperationManager shareManager] GETListWithURL:Olla_API_Share_CommentList parameters:parameters modelType:[LLComment class] success:^(NSArray *datas, BOOL hasNext) {
            
            weakSelf.loadingView.hasNext = hasNext;
            
            if (hasNext) {
                weakSelf.loadingView.statusLabel.hidden = YES;
                weakSelf.loadingView.page += 1;
            } else {
                weakSelf.loadingView.statusLabel.hidden = NO;
            }
            
            for (LLComment *comment in datas) {
                if (comment.objUsername.length > 0) {
                    comment.content = [NSString stringWithFormat:@"@%@ %@", comment.objUsername, comment.content];
                }
            }
            
//            [weakSelf.loadingView stopLoading];
//            [weakSelf.refreshControl endRefreshing];
            [myTableView.header endRefreshing];
            //            [weakSelf.dataSource addObjectsFromArray:datas];
            [weakSelf.commentListDataSource removeAllObjects];
            [weakSelf.commentListDataSource addObjectsFromArray:datas];
            
//            [weakSelf.tableView reloadData];
            
            [weakSelf hideHud];
            
            [myTableView reloadData];
            
        } failure:^(NSError *error) {
            [weakSelf hideHud];
            [myTableView.header endRefreshing];
//            [weakSelf.refreshControl endRefreshing];
        }];
        
    } failure:^(NSError *error) {
        [weakSelf hideHud];
//        [weakSelf.refreshControl endRefreshing];
        [myTableView.header endRefreshing];
    }];
    
    

}

- (void)refresh:(id)sender {
    
    self.loadingView.page = 1;
    [super refresh:sender];
    
    [self loadData];
    [UIView animateWithDuration:0.5 animations:^{
        [self.tableView reloadData];
    }];
}

// 加载更多数据
- (void)loadMoreData {
    
}

// 加载更多评论
- (void)loadMoreComment {

    [self.loadingView startLoading];
    __weak __block typeof(self) weakSelf = self;
    
    int size = self.loadingView.size;
    
    NSDictionary *parameters = @{@"shareId":weakSelf.share.shareId, @"pageId":@(self.loadingView.page), @"size":@(size)};
    
    [[LLHTTPRequestOperationManager shareManager] GETListWithURL:Olla_API_Share_CommentList parameters:parameters modelType:[LLComment class] success:^(NSArray *datas, BOOL hasNext) {
        
        weakSelf.loadingView.hasNext = hasNext;
        if (hasNext) {
            weakSelf.loadingView.statusLabel.hidden = YES;
            weakSelf.loadingView.page += 1;
        } else {
            weakSelf.loadingView.statusLabel.hidden = NO;
        }
        
        for (LLComment *comment in datas) {
            if (comment.objUsername.length > 0) {
                comment.content = [NSString stringWithFormat:@"@%@ %@", comment.objUsername, comment.content];
            }
        }
        
        [weakSelf.loadingView stopLoading];
        [weakSelf.commentListDataSource addObjectsFromArray:datas];
        [myTableView reloadData];
        
    } failure:^(NSError *error) {
        [weakSelf.loadingView stopLoading];
    }];
}

- (void)shareBar {
//    if (!shareVC) {
//        shareVC = [[LLShareViewController alloc] initWithNibName:@"LLShareViewController" bundle:nil];
//    }
    
    LLShare *post = self.share;
    
    NSString *host = [LLAppHelper baseAPIURL];
    
    NSString *url = [NSString stringWithFormat:@"%@/post/page.do?postId=%@", host, post.shareId];
    
    NSString *text = nil;
    
    if (post.content.length > 100) {
        text = [[post.content substringToIndex:100] stringByAppendingString:@"..."];
    } else {
        text = post.content;
    }
    
    NSString *shareText = [NSString stringWithFormat:@"%@ %@", text, url];
    
//    shareVC.shareTitle = @"post shared from olla:";
//    shareVC.shareText = shareText;
//    shareVC.shareURL = url;
    
    UIImage *shareImage = nil;
    
    if (post.imageList.count > 0) {
        NSURL *url = [NSURL URLWithString:post.imageList.firstObject];
        
        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
        if (image) {
            shareImage = image;
        }
    }
    
//    shareVC.shareImage = shareImage;
//    
//    [self.view.window addSubview:shareVC.view];
}

#pragma mark - config header cell
- (id)configTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LLShareDetailTableViewCellRefactor *shareHeaderCell = (LLShareDetailTableViewCellRefactor *)[tableView dequeueReusableCellWithIdentifier:@"LLShareDetailTableViewCellRefactor"];
    if (!shareHeaderCell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLShareDetailTableViewCellRefactor" owner:self options:nil];
        shareHeaderCell = (LLShareDetailTableViewCellRefactor *)[nib objectAtIndex:0];
    }
    
    LLShare *share = self.dataItemDataSource[0];
    
    shareHeaderCell.share = share;
    self.shareHeaderCell = shareHeaderCell;
    
    // 父类记录 改变显示个数
    self.headCell = shareHeaderCell;
    
    return shareHeaderCell;
}

- (CGFloat)heightForHeaderCell {

    if (!self.shareHeaderCell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLShareDetailTableViewCellRefactor" owner:self options:nil];
        self.shareHeaderCell = (LLShareDetailTableViewCellRefactor *)[nib objectAtIndex:0];
        self.shareHeaderCell.share = self.share;
    }
    return [self.shareHeaderCell shareDetaileCellHeight];
}

#pragma mark - Like & Unlike
- (void)like {
    
    // url str
    NSString *url = nil;
    LLShare *dataItem = self.params;
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
//    if (dataItem.bar) {
//        // post
//        url = Olla_API_Groupbar_Post_Like;
//        para[@"postId"] = dataItem.shareId;
//    } else {
        // share
        url = Olla_API_Share_Like;
        para[@"shareId"] = dataItem.shareId;
//    }
    
    
    __weak typeof(self) weakSelf = self;
    [[LLHTTPWriteOperationManager shareWriteManager]
     GETWithURL:url
     parameters:para
     success:^(id datas , BOOL hasNext){
         
         __strong typeof(self) strongSelf = weakSelf;
         // TODO: like成功
         
         [strongSelf likeSuccessHandler:datas];
         
     } failure:^(NSError *error){
         
         DDLogError(@"like error:%@",error);
         
         __strong typeof(self) strongSelf = weakSelf;
         // TODO: like失败
         [strongSelf likeFailureHandler:error];
         
         //[JDStatusBarNotification showWithStatus:@"like failed" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
         
     }];
}

- (void)unlike {
    
    // url str
    NSString *url = nil;
    LLShare *dataItem = self.params;
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
//    if (dataItem.bar) {
//        // post
//        url = Olla_API_Groupbar_Post_Unlike;
//        para[@"postId"] = dataItem.shareId;
//    } else {
        // share
        url = Olla_API_Share_Unlike;
        para[@"shareId"] = dataItem.shareId;
//    }
    
    __weak typeof(self) weakSelf = self;
    [[LLHTTPWriteOperationManager shareWriteManager] GETWithURL:url parameters:para success:^(id datas , BOOL hasNext){
        
        DDLogInfo(@"API Log:%@",datas);
        
        __strong typeof(self) strongSelf = weakSelf;
        // TODO: like成功
        
        [strongSelf unlikeSuccessHandler:datas];
        
        //                if (![datas boolValue]) {
        //                    [JDStatusBarNotification showWithStatus:@"unlike failed" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        //                }
        
        
    } failure:^(NSError *error){
        
        DDLogError(@"取消点赞失败：%@",error);
        
        __strong typeof(self) strongSelf = weakSelf;
        // TODO: like成功
        [strongSelf unlikeFailureHandler:error];
        
        //[JDStatusBarNotification showWithStatus:@"unlike failed" dismissAfter:1.f styleName:JDStatusBarStyleDark];
    }];
}


- (void)enrollSuccessHandler:(id)data {
    
    [self hideHud];
     [myTableView reloadData];
}

- (void)enrollFailureHandler:(id)data
{
    
    // do something
    [self hideHud];
    
    NSError *error = data;
    
    if ([[error.userInfo objectForKey:@"status"] isEqualToString:@"DataIntegrityViolationException"]) {
        [self unlike];
    }
    [UIAlertView showWithTitle:nil message:error.userInfo[@"message"] cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
     NSLog(@"%@",error.userInfo[@"message"]);
}

- (void)unenrollSuccessHandler:(id)data {
    
    [self hideHud];
    [myTableView reloadData];
}

- (void)unenrollFailureHandler:(id)data {
    
    // do something
    [self hideHud];
    NSError *error = data;
    
    if ([[error.userInfo objectForKey:@"status"] isEqualToString:@"DataIntegrityViolationException"]) {
        [self like];
    }
    
}
- (void)likeSuccessHandler:(id)data {
    
    [self hideHud];
    LLUser *user = [userService getMe];
 
    LLSimpleUser *su = [[LLSimpleUser alloc] init];
    su.uid = user.uid;
    su.userName = user.userName;
    su.avatar = user.avatar;
    su.nickname = user.nickname;
    su.gender = user.gender;
    su.region = user.region;
    LLSimpleUser *me = su;
    [self.likeUsersInfos insertObject:me atIndex:0];
    
    LLLike *like = [[LLLike alloc] init];
    
    like.uid = me.uid;
    like.avatar = me.avatar;
    like.sign = me.sign;
    like.voice = me.voice;
    like.distanceText = me.distanceText;
    like.gender = me.gender;
    like.location = me.location;
    like.nickname = me.nickname;
    
    like.user = me;
    
    [self.likeList insertObject:like atIndex:0];
    
    // 如果原来有点赞列表则替换,如果无则插入
    self.likeListDataSource = [self.likeList mutableCopy];
    
    self.share.goodCount += 1;
    [self.shareHeaderCell changeLikeNum:YES];
    [myTableView reloadData];
}

- (void)likeFailureHandler:(id)data {
    
    // do something
    [self hideHud];
    
    NSError *error = data;
    
    if ([[error.userInfo objectForKey:@"status"] isEqualToString:@"DataIntegrityViolationException"]) {
        [self unlike];
    }
}

- (void)unlikeSuccessHandler:(id)data {
    
    [self hideHud];
    
    LLUser *user = [userService getMe];
    
    LLSimpleUser *su = [[LLSimpleUser alloc] init];
    su.uid = user.uid;
    su.userName = user.userName;
    su.avatar = user.avatar;
    su.nickname = user.nickname;
    su.gender = user.gender;
    su.region = user.region;
    LLSimpleUser *me = su;
    for (int i = 0; i < self.likeUsersInfos.count; i++) {
        LLSimpleUser *temp = self.likeUsersInfos[i];
        if ([me.uid isEqualToString:temp.uid]) {
            [self.likeUsersInfos removeObject:temp];
            break;
        }
    }
    
    for (int i = 0; i < self.likeList.count; i++) {
        LLLike *like = self.likeList[i];
        if ([me.uid isEqualToString:[NSString stringWithFormat:@"%d", like.uid.intValue]]) {
            [self.likeList removeObject:like];
            break;
        }
    }
    
    // 如果原来点赞数为1,则移除goodlist,如果大于1,则替换
    self.likeListDataSource = [self.likeList mutableCopy];
    
    self.share.goodCount -= 1;
    if (self.share.goodCount < 0) {
        self.share.goodCount = 0;
    }
    [self.shareHeaderCell changeLikeNum:NO];
    [myTableView reloadData];
}

- (void)unlikeFailureHandler:(id)data {
    
    // do something
    [self hideHud];
    NSError *error = data;
    
    if ([[error.userInfo objectForKey:@"status"] isEqualToString:@"DataIntegrityViolationException"]) {
        [self like];
    }
    
}

- (BOOL)isLike {
    
    LLUser *user = [userService getMe];
    
    LLSimpleUser *su = [[LLSimpleUser alloc] init];
    su.uid = user.uid;
    su.userName = user.userName;
    su.avatar = user.avatar;
    su.nickname = user.nickname;
    su.gender = user.gender;
    su.region = user.region;
    LLSimpleUser *me = su;
    NSString *myUID = me.uid;
    
    NSMutableArray *likeUserUID = [NSMutableArray array];
    for (LLSimpleUser *simpleUser in self.likeUsersInfos) {
        [likeUserUID addObject:simpleUser.uid];
    }
    
    BOOL isLike;
    if ([likeUserUID containsObject:myUID]) {
        isLike = YES;
    } else {
        isLike = NO;
    }
    
    return isLike;
}

#pragma mark - Report Share
- (void)reportShare:(id)sender
{

    [UIAlertView showWithTitle:nil message:@"Are you sure to report to administrator to block it？" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Sure"] tapBlock:^(UIAlertView *alertView,NSInteger index){
        
        if (index == 1) {  // Sure
            
            //                __weak typeof(self) weakSelf = self;
            [[LLHTTPWriteOperationManager shareWriteManager]
             GETWithURL:Olla_API_report
             parameters:@{@"shareId":self.share.shareId}
             success:^(id datas , BOOL hasNext){
                 
                 NSString *message = @"Report success";
                 [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
                 
                 // 举报成功不需要处理什么事件,故注释掉
                 //                     __strong typeof(self) strongSelf = weakSelf;
                 //                     [strongSelf successHandler:datas];
                 
                 
             } failure:^(NSError *error){
                 DDLogError(@"report error:%@",error);
                 //[JDStatusBarNotification showWithStatus:@"report fail" dismissAfter:1.f styleName:JDStatusBarStyleDark];
             }];
        }
        
    }];
}

#pragma mark - Delete
// 删除share的功能  //// ////////////
//- (IBAction)deleteButtonClicked:(id)sender
//{
//    
//    [self.toolBarView.inputTextView resignFirstResponder];
//    
//    LLBottomActionSheet *sheet = [[LLBottomActionSheet alloc]
//                                  initWithTitle:@"确定让该分享下架吗?"
//                                  message:nil
//                                  delegate:self
//                                  cancelButtonTitle:@"放弃"
//                                  confirmButtonTitles:@"删除"];
//    [sheet setStyle:SheetRedButton];
//    [sheet show];
//}
//
//-(void)sheetSelecteButton:(NSInteger)buttonIndex sheetView:(LLBottomActionSheet *)sheetView
//{
//    if (buttonIndex == 1) {
//        [self doDelete:sheetView];
//    }
//}

- (void)doDelete:(id)sender
{
    
    if ( ![[[userService getMe] uid] isEqualToString:self.share.user.uid] )
    {
        [UIAlertView showWithTitle:nil
                           message:@"无权限删除贴子."
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"确定"]
                          tapBlock:^(UIAlertView *alertView,NSInteger tapIndex)
        {
            
            
        }];
    }
    else
    {
        [self showHudInView:self.view hint:nil];
        [[LLHTTPRequestOperationManager shareManager]
         GETWithURL:LBSLM_API_Share_Delete
         parameters:@{@"shareId":self.share.shareId}
         success:^(id data,BOOL hasNext)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaShareDeleteNotification" object:nil userInfo:@{@"shareId":self.share.shareId}];
             [self hideHud];
             [self openURL:[NSURL URLWithString:@"." relativeToURL:self.url] animated:YES];
         }
         failure:^(NSError *error)
         {
             [self hideHud];
         }];
        if([[self.url absoluteString] hasPrefix:@"present:"])
        {
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        }
        else [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - button click event
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    
    [super routerEventWithName:eventName userInfo:userInfo];
    if ([eventName isEqualToString:LLShareDetailLikeButtonClickEvent]) {  // Like
        
        
        [self showHudInView:self.view hint:nil];
        
        if ([self isLike]) {  // liked, and will send unlike request
            [self unlike];
        } else {  // send like request
            [self like];
        }
        // 发送valueDidChange通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LLShareOrPostDetailValueDidChange" object:nil];
        
    }
    if ([eventName isEqualToString:LLShareDetailEnrollButtonClick])
    {
        


        // 发送valueDidChange通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"LLShareOrPostDetailValueDidChange" object:nil];
        
    }
    else if ([eventName isEqualToString:LLShareDetailCommentButtonClickEvent])
    {  // Comment
        [self.toolBarView.inputTextView becomeFirstResponder];
    } else if ([eventName isEqualToString:LLShareDetailAvatarButtonClick]) {  // to profile of the owner of the share
        LLSimpleUser *user = [userInfo objectForKey:@"avatorClick"];
        
//        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
//        [query setValue:@(1) forKey:@"flag"];
//        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
        [dict setValue:@1 forKey:@"flag"];
        [self openURL:[self.url URLByAppendingPathComponent:@"im" queryValue:dict] animated:YES];
        
        
    }

    else if ([eventName isEqualToString:LLFollowButtonClickEvent]) {
        // 判断是否follow

        LLSimpleUser *simpleUser = [userInfo objectForKey:@"shareOwner"];
        [userService get:simpleUser.uid success:^(LLUser *user)
        {

            if (user.follow)
            {
                //fansCell.followStateLabel.text = @"+ Follow";  // 无问题
                // 发送"Unfollow"消息
                [userService unfollow:simpleUser];
                
            }
            else {
               // fansCell.followStateLabel.text = @"Followed";
                // 发送"Follow"消息
                [userService follow:simpleUser];
                
            }
        } fail:^(NSError *error) {
            
        }];
        
    

    }
    else if ([eventName isEqualToString:LLShareTextPhoneNumberClickEvent]) {
        NSString *phoneNumber = userInfo[@"phoneNumber"];
        PSTAlertController *alertVC = [PSTAlertController alertControllerWithTitle:phoneNumber message:nil preferredStyle:PSTAlertControllerStyleAlert];
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Copy" handler:^(PSTAlertAction *action) {
            [[UIPasteboard generalPasteboard] setString:phoneNumber];
            [self showHint:@"Copy to pasteboard"];
        }]];
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Call" handler:^(PSTAlertAction *action) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
            [[UIApplication sharedApplication] openURL:url];
        }]];
        
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Cancel" style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
            
        }]];
        
        [alertVC showWithSender:nil controller:self animated:YES completion:nil];
    }
    else if([eventName isEqualToString:LLShareDetailReportButtonClick])
    {
        __weak __block typeof(self) weakSelf = self;
        
        PSTAlertController *alertVC = [PSTAlertController alertControllerWithTitle:@"你确定举报该内容吗？"
                                                                           message:nil
                                                                    preferredStyle:PSTAlertControllerStyleAlert];
        
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"确定"
                                                   handler:^(PSTAlertAction *action)
        {
            
            [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_report
                                                          parameters:@{@"shareId":self.share.shareId}
                                                             success:^(id datas, BOOL hasNext)
             {
                 [weakSelf showHint:@"已举报，等待管理员审核"];
             }
                                                             failure:^(NSError *error)
             {
                 NSString *errorMsg = [error.userInfo stringForKey:@"message"];
                 if (errorMsg.length == 0) {
                     errorMsg = error.localizedDescription;
                 }
                 
                 [PSTAlertController showMessage:errorMsg];
             }];
            
        }]];
        
        [alertVC addCancelActionWithHandler:^(PSTAlertAction *action) {
            
        }];
        
        [alertVC showWithSender:nil controller:nil animated:YES completion:NULL];
    }
    
}

#pragma mark - 收藏




- (void)doFavorite {
    
    [self showHudInView:self.view hint:@""];
    @weakify(self);
    [[LLHTTPWriteOperationManager shareWriteManager] GETWithURL:Olla_API_Share_Favorite parameters:@{@"shareId":self.share.shareId} success:^(id datas, BOOL hasNext) {
        
        @strongify(self);
        [self hideHud];
        [JDStatusBarNotification showWithStatus:@"Favorite succeeded." dismissAfter:1.f styleName:JDStatusBarStyleDark];
        LLShare *share = [self.dataItemDataSource firstObject];
        share.favorite = YES;
        
        [self.dataItemDataSource removeAllObjects];
        [self.dataItemDataSource addObject:share];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self hideHud];
        [JDStatusBarNotification showWithStatus:@"Favorite failed." dismissAfter:1.f styleName:JDStatusBarStyleDark];
    }];
}

- (void)doCancelFavorite {
    
    [self showHudInView:self.view hint:@""];
    @weakify(self);
    [[LLHTTPWriteOperationManager shareWriteManager] GETWithURL:Olla_API_Share_Favorite_Cancel parameters:@{@"shareId":self.share.shareId} success:^(id datas, BOOL hasNext) {
        
        @strongify(self);
        [self hideHud];
        [JDStatusBarNotification showWithStatus:@"Cancel favorite succeeded." dismissAfter:1.f styleName:JDStatusBarStyleDark];
        LLShare *share = [self.dataItemDataSource firstObject];
        share.favorite = NO;
        
        [self.dataItemDataSource removeAllObjects];
        [self.dataItemDataSource addObject:share];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self hideHud];
        [JDStatusBarNotification showWithStatus:@"Cancel favorite failed." dismissAfter:1.f styleName:JDStatusBarStyleDark];
    }];
}

// 内部分享
//- (void)shareToOllaWithExt:(LLShareExt *)shareExt {
//    
//    if (shareExt.userInfo[@"share"]) {
//        LLShare *share = shareExt.userInfo[@"share"];
//        NSDictionary *params = @{@"type":@"4",
//                                 @"share":share};
//        NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"groupbar-addmember"]];
//        [self openURL:url params:params animated:YES];
//    }
//}

#pragma mark - Record button delegate
/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    if ([self canRecord]) {
        DXRecordView *tmpView = (DXRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        
//        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName
//                                                                 completion:^(NSError *error)
//         {
//             if (error) {
//                 NSLog(@"%@",error);
//             }
//         }];
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
//    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
//    __weak typeof(self) weakSelf = self;
//    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
//        if (!error) {
//            EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath
//                                                       displayName:@"audio"];
//            voice.duration = aDuration;
////            NSData *recordData = [NSData dataWithContentsOfFile:recordPath];
////            NSError *error = nil;
////            NSData *recordData = [NSData dataWithContentsOfFile:recordPath options:NSDataReadingMappedAlways error:&error];
////            NSLog(@"error : %@", error);
////            [weakSelf sendAudioMessage:voice];
//#warning 此处改为发送评论
//            [weakSelf sendCommentWithVoice:voice];
//        }else {
//            [weakSelf showHudInView:self.view hint:@"Record too short"];
////            weakSelf.chatToolBar.recordButton.enabled = NO;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf hideHud];
////                weakSelf.chatToolBar.recordButton.enabled = YES;
//            });
//        }
//    }];
}

- (void)sendCommentWithVoice:(EMChatVoice *)voice {
    
    if (![self check]) {
        return;
    }
    
#warning 需要检查是否为空
//    // send comment
//    if (!self.toolBarView.selectedPhoto && [text length]==0) {
//        return ;
//    }
    
    // if the user has been blocked, he or she would not be allowed sending comment.
    if ([self checkIsBlocked]) {
        DDLogInfo(@"you are blocked! you can not send message to others");
        [UIAlertView showWithTitle:nil message:@"Sorry,you cannot send message because of report" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        
        return;
    }
    
    // send comment request
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    if (self.share) {
        [parameters setObject:self.share.shareId forKey:@"shareId"];
//    } else {
//        [parameters setObject:self.post.postId forKey:@"postId"];
//    }
    
//    __weak typeof(self) weakSelf = self;
    
    [self showHudInView:self.view hint:nil];
    NSString *url = nil;
    if (self.share) {
        url = Olla_API_Share_Comment;
    } else {
        url = Olla_API_Post_Comment;
    }

    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSData *voiceData = [NSData dataWithContentsOfFile:voice.localPath];
//    [parameters setObject:voiceData forKey:@"voice"];
    [parameters setObject:@"voice" forKey:@"type"];
    [parameters setObject:@(voice.duration) forKey:@"vlen"];
    [[LLHTTPWriteOperationManager shareWriteManager] POSTWithURL:url parameters:parameters data:voiceData success:^(NSDictionary *responseObject) {
        DDLogInfo(@"upload ok:%@", responseObject[@"data"]);
        [self voiceCommentSucceedHandler:responseObject];
        
    } failure:^(NSError *error) {
        DDLogError(@"whatup语音 upload error:%@",error);
        [self voiceCommentFailHandler:error];
    }];

//        DDLogInfo(@"upload ok:%@",respond);
////        [self updateValue:respond[@"data"] forKey:@"voice"];
////        success(respond);
//        [self.commentListDataSource addObject:[respond objectForKey:@"data"]];
//        [myTableView reloadData];

}

- (void)voiceCommentFailHandler:(NSError *)error {

    // ..
}

- (void)voiceCommentSucceedHandler:(NSDictionary *)para {
    
//    if (self.headCell) {
        self.headCell.share.commentCount += 1;
//    } else {
//        self.categoryHeadCell.post.commentCount += 1;
//    }
    
    [super reloadComments];
}

#pragma mark - privite
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
