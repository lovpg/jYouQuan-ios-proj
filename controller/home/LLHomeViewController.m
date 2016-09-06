//
//  LLHomeViewController.m
//  jishou
//
//  Created by Reco on 16/7/19.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//


#import "LLHomeViewController.h"
#import "LLHomeHeadCell.h"
#import "LLLoadingView.h"
#import "LLHomeShareViewCell.h"
#import "LLShareMessage.h"
#import "LLShareDataSource.h"
#import "LLSupplyProfileService.h"
#import "AppDelegate.h"
#import "LLShareButton.h"
#import "LLTenMilesCircle.h"
#import "LLHomeHeadCell.h"
#import "LLThirdCollection.h"
#import "LLHomeBannerCell.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height//获取屏幕高度，兼容性测试
#define span 10000
@interface LLHomeViewController() < UITableViewDataSource, UITableViewDelegate,
LLShareDataSourceDelegate>
{
    LLUserService *userService;
    OllaImagePickerController *imagePickerController;
    LLShareDataSource *shareDataSource;
    LLTenMilesCircle * tmc;
    NSInteger *tmcid;
}
@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
// dataSource
@property (weak, nonatomic) IBOutlet UIImageView *customImageView;
@property (strong, nonatomic) NSMutableArray *userInfoDataSource;  // 存放headCell中用户的信息
@property (strong, nonatomic) NSMutableArray *shareDataSource;  // 存放share和groupbar post
@property (strong, nonatomic) UIImageView *flagView;
@property (assign, nonatomic) NSInteger flagCount;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) LLHomeHeadCell *headCell;
@property (strong, nonatomic) LLUser *user;
@property (strong, nonatomic) LLLoadingView *loadingView;
@property (strong, nonatomic) NSMutableArray *dataObjects;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) UIImageView *nRedPoint;
@property (weak, nonatomic) IBOutlet UIScrollView *activityScrollView;

//@property (strong, nonatomic) LLShareExt *shareExt;

@end

@implementation LLHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _userInfoDataSource = [NSMutableArray array];
        _shareDataSource = [NSMutableArray array];
        _dataObjects = [NSMutableArray array];
        
        shareDataSource = [[LLShareDataSource alloc] init];
        shareDataSource.delegate = self;
    }
    return self;
}

- (NSMutableArray *)friends
{
    if (!_friends)
    {
        _friends = [NSMutableArray array];
    }
    return _friends;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    userService = [[LLUserService alloc] init];
    self.qrView.hidden = YES;
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"me_setting"] forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    rightButton.layer.cornerRadius = 3.f;
    [rightButton addTarget:self action:@selector(settingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.backgroundColor = [UIColor clearColor];
    UIImageView *redPoint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge_number_bg"]];
    self.nRedPoint = redPoint;
    redPoint.frame = CGRectMake(rightButton.width - 10, 0, 10, 10);
    [rightButton addSubview:redPoint];
    UIBarButtonItem *proe = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = proe;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RGB_DECIMAL(247, 247, 247);
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(238, 0, 0, 0)];
    
    tmc = self.params;
    self.titleLabel.text = tmc.tmcname;
    if( ![tmc.follow isEqualToString:@"1"] )
    {
        self.qrScanButton.hidden = YES;
    }
    // 获取个人信息
    LLUser *user = [userService getMe];
    self.user = user;
    [self.userInfoDataSource removeAllObjects];
    [self.userInfoDataSource addObject:user];
    [self.avatorButton sd_setBackgroundImageWithURL:[NSURL URLWithString:tmc.avator]
                                           forState:UIControlStateNormal
                                   placeholderImage:[UIImage imageNamed:@"headphoto_default_128"]];
    self.avatorButton.cornerRadius = self.avatorButton.height / 2.f;
    self.signLabel.text = tmc.sign;
    if( [tmc.follow isEqualToString:@"1"] )
    {
        self.followButton.hidden = YES;
    }
    // 添加国旗按钮
    UIImageView *flagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_flag"]];
    flagView.frame = CGRectMake(5, 5, 20, 20);
    flagView.userInteractionEnabled = NO;
    flagView.hidden = NO;
    self.flagView = flagView;
    [self flagViewHandler];
    
    
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh:)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.header = header;
    
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




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

#pragma mark - Load Data & Load More & Refresh & Load Cache Data

- (void)loadCacheData
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"pageId"] = @(1);
    params[@"size"] = @(20);
    params[@"tmcid"] = @([tmc.tmcid intValue]);
    
    NSArray *cacheArray = [[LLAPICache sharedCache] cacheArrayWithURL:LBS_API_Share_Focus
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
     GETListWithURL:LBS_API_Share_Focus
     parameters:@{
                  @"tmcid":@([tmc.tmcid intValue]),
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
         //         [strongSelf.shareDataSource removeAllObjects];
         //         [strongSelf.shareDataSource addObjectsFromArray:datas];  olla#1234
         // 做过滤
         [strongSelf.shareDataSource removeAllObjects];
         strongSelf.shareDataSource = [self dataFilter:datas];
         for (int i = 0; i < [ datas count]; i++)
         {
             LLShare *share = [ datas objectAtIndex:i];
             
         }
         [strongSelf.tableView reloadData];
         [strongSelf.tableView.header endRefreshing];
     }
     failure:^(NSError *error)
     {
         [weakSelf.tableView.header endRefreshing];
     }];
    
    
    
    
    
}

- (void)loadMoreData
{
    
    int page = self.loadingView.page;
    int size = self.loadingView.size;
    NSLog(@"page : %d", page);
    
    [self.loadingView startLoading];
    
    __weak __block typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager]
     GETListWithURL:LBS_API_Share_Focus
     parameters:@{
                  @"tmcid":@([tmc.tmcid intValue]),
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
         //         [strongSelf.shareDataSource addObjectsFromArray:datas];
         // 做过滤
         [strongSelf.shareDataSource addObjectsFromArray:[self dataFilter:datas]];
         // *****
         [strongSelf.tableView reloadData];
         
         [strongSelf.loadingView stopLoading];
     } failure:^(NSError *error){
         
         [weakSelf.loadingView stopLoading];
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

- (void)refresh:(id)sender
{
    
    [self loadData];
}
- (IBAction)followButton:(id)sender
{
//    
//    [tmcService follow:tmc.tmcid
//               success:^(LLTenMilesCircle *tmc)
//     {
//         NSString *message = @"关注成功.";
//         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
//     }
//                  fail:^(NSError *error)
//     {
//         
//     }];
    
}

#pragma mark - 个人资料更新 刷新head cell
- (void)refreshHeadCell:(NSNotification *)notification {
    
    // 获取个人信息
    if (!userService) {
        userService = [[LLUserService alloc] init];
    }
    LLUser *user = [userService getMe];
    self.user = user;
    
    if ([notification.name isEqualToString:@"OllaCoverPhotoChangeNotification"]) {
        user.cover = [notification.userInfo objectForKey:@"cover"];
    }
    
    [self.userInfoDataSource removeAllObjects];
    [self.userInfoDataSource addObject:user];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - 在详情里面有进行点赞或者评论操作,要进行数据刷新
/*
 问题 : 在进行评论或者点赞操作后,数据虽然进行刷新,但是数据不吻合,详情里面数据评论数加1,
 在me里面重新获取数据的评论数没有加1
 */
- (void)updateData {
    
    self.loadingView.page = 1;
    
    [self.tableView.header beginRefreshing];
    
    __weak __block typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager]
     GETListWithURL:Olla_API_TMC_SHARES
     parameters:@{
                  @"tmcid":@([tmc.tmcid intValue]),
                  @"pageId":@(1),
                  @"size":@(20)
                  }
     modelType:[LLShare class]
     needCache:YES
     success:^(NSArray *datas , BOOL hasNext){
         
         __strong __typeof(self)strongSelf = weakSelf;
         strongSelf.loadingView.hasNext = hasNext;
         if (hasNext) {
             self.loadingView.page += 1;
         }
         
         [strongSelf.shareDataSource removeAllObjects];
         [strongSelf.shareDataSource addObjectsFromArray:datas];
         
         NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:2];
         [strongSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
         
         [strongSelf.tableView.header endRefreshing];
         
         //         // 暂时不做过滤
         //         [strongSelf loadResultsData:datas];
         
         
     } failure:^(NSError *error){
         //         [self downlinkTaskDidFitalError:error forTaskType:nil];
         
         [weakSelf.tableView.header endRefreshing];
     }];
}

#pragma mark - Post share
// 跳到发表新帖的页面
- (void)jumpToPostShare {
    //    LLPostShareViewController *postVC = [[LLPostShareViewController alloc] init];
    //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postVC];
    //    [self presentViewController:nav animated:YES completion:nil];
    //    [self openURL:[NSURL URLWithString:@"present:///root/publish"] animated:YES];
}

#pragma mark - Flag
- (void)flagViewHandler {
    
    //    NSArray *friends = [LLFriendInfo SQPFetchAll];
    NSArray *friends = [LLUser myFriends];
    [self.friends removeAllObjects];
    self.friends = [friends mutableCopy];
    if (friends.count > 0) {
        NSInteger flagCount = [LLAppHelper flagCountWithFriendList:friends];
        self.flagCount = flagCount;
    } else {
        
        __weak __block typeof(self) weakSelf = self;
        
        //        [[LLFriendsFetcher sharedFetcher] fetchWithSuccess:^(NSArray *array) {
        //            NSInteger flagCount = [LLAppHelper flagCountWithFriendList:array];
        //            weakSelf.flagCount = flagCount;
        //            weakSelf.flagView.hidden = NO;
        //            [weakSelf.tableView reloadData];
        //        } error:^(NSError *error) {
        //
        //        }];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger count = 0;
    if (section == 0)
    {
        count = 1;
    }
    else
    {
        count = self.shareDataSource.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0)
    {
        LLHomeBannerCell *bannerCell = (LLHomeBannerCell *)[tableView dequeueReusableCellWithIdentifier:@"LLHomeBannerCell"];
        if (!bannerCell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLHomeBannerCell" owner:self options:nil];
            bannerCell = (LLHomeBannerCell *)[nib objectAtIndex:0];
        }
        cell = bannerCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    else
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
    if(indexPath.section == 0)
    {
        height = 140;
    }
    else
    {
        LLHomeShareViewCell *shareCell =  [[LLHomeShareViewCell alloc] init];
        shareCell.displayLocation = YES;
        height = [shareCell shareCellHeight:self.shareDataSource[indexPath.row]];
    }
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        if ((indexPath.row == self.shareDataSource.count - 1) && self.loadingView.hasNext)
        {
            [self loadMoreData];
        }
    }
}

#pragma mark - Record & Play record



// 更新button的状态
- (void)recordUpdateSuccessHandler:(NSNotification *)notification
{
    //    audioButton.enabled = ([[userService whatsupAudioPath] length]!=0);
}



- (UITabBar *)tabbar
{
    return self.tabBarController.tabBar;
}

#pragma mark - Router
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    
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
        if (isGood) {
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
    }
    else if ([eventName isEqualToString:LLScrollBannerButtonClickEvent])
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
//    else if ([eventName isEqualToString:LLMyCenterShareThirdPlatfomButtonClickEvent])
//    {
//        LbslmWebViewController *lvc = [[LbslmWebViewController alloc]initWithNibName:@"LbslmWebViewController" bundle:nil];
//        LLShare *dataItem = [userInfo objectForKey:@"dataItem"];
//        LLThirdCollection *collection = dataItem.collection;
//        lvc.urlString = collection.url;
//        [self.navigationController pushViewController:lvc animated:true];
//    }
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
        if(user.uid == self.user.uid)return;
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
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}



#pragma mark - Share
- (void)shareWithPost:(LLShare *)dataItem {
    //
    //    NSString *host = [LLAppHelper baseAPIURL];
    //    NSString *url = [NSString stringWithFormat:@"%@/post/page.do?postId=%@", host, dataItem.shareId];
    //
    //    NSString *wxHost = [LLAppHelper wxBaseAPIURL];
    //    NSString *wxURL = [NSString stringWithFormat:@"%@/post/page.do?postId=%@", wxHost, dataItem.shareId];
    //
    //    LLShareExt *ext = [LLShareExt new];
    //    ext.ollaViewHidden = NO;
    //    ext.userInfo = @{@"post":dataItem};
    //    ext.shareTitle = @"Post shared from olla";
    //
    //    ext.shareURL = url;
    //    ext.wxShareURL = wxURL;
    //
    //    if (dataItem.imageList.count) {
    //        NSURL *url = [NSURL URLWithString:dataItem.imageList.firstObject];
    //        NSString *shareImageURL = [dataItem.imageList.firstObject stringByReplacingOccurrencesOfString:@".jpg" withString:@"_120x120_crop.jpg"];
    //        ext.shareImageURL = shareImageURL;
    //
    //        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    //        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    //        if (image) {
    //            ext.shareImage = image;
    //        }
    //    } else {
    //        ext.shareImageURL = @"http://olla.im/static/img/olla_for_fb.png";
    //    }
    //
    //
    //    LLShareView *shareView = [LLShareView new];
    //    shareView.shareExt = ext;
    //    shareView.delegate = self;
    //    [shareView show];
}

- (void)shareWithShare:(LLShare *)dataItem {
    //
    //    NSString *host = [LLAppHelper baseAPIURL];
    //    NSString *url = [NSString stringWithFormat:@"%@/post/page.do?postId=%@", host, dataItem.shareId];
    //
    //    NSString *wxHost = [LLAppHelper wxBaseAPIURL];
    //    NSString *wxURL = [NSString stringWithFormat:@"%@/post/page.do?postId=%@", wxHost, dataItem.shareId];
    //
    //    LLShareExt *ext = [LLShareExt new];
    //    ext.ollaViewHidden = NO;
    //    ext.userInfo = @{@"share":dataItem};
    //    ext.shareTitle = @"Share shared from olla";
    //
    //    ext.shareURL = url;
    //    ext.wxShareURL = wxURL;
    //
    //    if (dataItem.imageList.count) {
    //        NSURL *url = [NSURL URLWithString:dataItem.imageList.firstObject];
    //        NSString *shareImageURL = [dataItem.imageList.firstObject stringByReplacingOccurrencesOfString:@".jpg" withString:@"_120x120_crop.jpg"];
    //        ext.shareImageURL = shareImageURL;
    //
    //        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    //        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    //        if (image) {
    //            ext.shareImage = image;
    //        }
    //    } else {
    //        ext.shareImageURL = @"http://olla.im/static/img/olla_for_fb.png";
    //    }
    //
    //
    //    LLShareView *shareView = [LLShareView new];
    //    shareView.shareExt = ext;
    //    shareView.delegate = self;
    //    [shareView show];
}

#pragma mark - vk 分享
//////////////////////////////// vk分享 ////////////////////////////////////////////////


- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

- (void)authorize:(id)sender {
    //    [VKSdk authorize:SCOPE];
}



//////////////////////////////// vk分享 ////////////////////////////////////////////////

// 内部分享


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
- (IBAction)qrScanButtonClick:(id)sender
{
    self.qrView.hidden = NO;
    //二维码处理
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [tmc.token dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"InputMessage"];
    CIImage *ciImage = [filter outputImage];
    self.customImageView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.customImageView.layer.shadowRadius = 1;
    self.customImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.customImageView.layer.shadowOpacity = 0.3;
    
    self.customImageView.image = [self createNonInterpolatedUIImageFormCIImage:ciImage size: 500];
}

- (IBAction)downloadQrButtonClick:(id)sender
{
    
}
- (IBAction)reGengerateButtonClick:(id)sender
{
    
}
- (IBAction)closeQrButtonClick:(id)sender
{
    self.qrView.hidden = YES;
}

#pragma mark - News Notify Click
- (IBAction)newsCommentClick:(id)sender {
    
    [self doComment:sender];
}

// 点击新评论通知
- (void)doComment:(id)sender
{
    
    [self openURL:[self.url URLByAppendingPathComponent:@"share-messages" queryValue:nil]  params:nil animated:YES];
    
}

- (void)hideMessageNotification
{
    
}
/****
 **
 ** 生成二维码
 **
 ***/
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)ciImage size:(CGFloat)widthAndHeight
{
    CGRect extentRect = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(widthAndHeight / CGRectGetWidth(extentRect), widthAndHeight / CGRectGetHeight(extentRect));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extentRect) * scale;
    size_t height = CGRectGetHeight(extentRect) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extentRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extentRect, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage]; // 黑白图片
    // UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
    //return [self imageBlackToTransparent:newImage withRed:200.0f andGreen:70.0f andBlue:189.0f];
}

void ProviderReleaseData (void *info, const void *data, size_t size)
{
    free((void*)data);
}
/***
 ** 设置图片透明度
 **
 **/
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue
{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}
#pragma mark - Share Delete Handler
// 删除帖子时做相关处理
- (void)shareDeleteHandler:(NSNotification *)notification{
    
    //    NSString *shareID = [notification.userInfo valueForKey:@"shareId"];
    //    [_tableController deleteShare:shareID];
    //    [self updateNewComments];
    
    // 刷新数据
    [self loadData];
    
}



#pragma mark - setting
- (void)settingButtonClick:(id)sender {
    
    NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"setting"]];
    [self openURL:url params:nil animated:YES];
}

#pragma mark - others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
