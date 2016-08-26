//
//  LLMyCenterViewControllerRefactor.m
//  Olla
//
//  Created by Charles on 15/8/14.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLMyCenterViewControllerRefactor.h"
#import "LLMyCenterHeadTableViewCell.h"
//#import "LLVoicePresentationViewController.h"
#import "LLLoadingView.h"
#import "LLMyCenterShareTableViewCellRefactor.h"
//#import "LLTranslateViewController.h"
#import "LLShareMessage.h"
#import "LLShareDataSource.h"
//#import "LLShareViewController.h"
//#import "LLShareView.h"
//#import "LLPostShareViewController.h"
#import "LLSupplyProfileService.h"
//#import <VKSdk/VKSdk.h>
//#import "LLMyWalletViewController.h"#
#import "AppDelegate.h"
#import "LLShareButton.h"
#import "LLThirdCollection.h"

static NSString *const APP_ID_IOS = @"5121183";
static NSString *const TOKEN_KEY = @"wS1ZGxzlTOtMafK39lJV";
static NSArray *SCOPE = nil;

@interface LLMyCenterViewControllerRefactor () <UITableViewDataSource, UITableViewDelegate, LLShareDataSourceDelegate> {
    
    LLUserService *userService;
    
    OllaImagePickerController *imagePickerController;
    
//    LLVoicePresentationViewController *vpVC;
//    
//    LLAudioPlayAnimationButton *audioButton;
    
    LLShareDataSource *shareDataSource;
    
//    LLShareViewController *shareVC;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// dataSource
@property (strong, nonatomic) NSMutableArray *userInfoDataSource;  // 存放headCell中用户的信息
@property (strong, nonatomic) NSMutableArray *notificationMessageDataSource;  // 存放新消息通知
@property (strong, nonatomic) NSMutableArray *shareDataSource;  // 存放share和groupbar post

@property (strong, nonatomic) UIImageView *flagView;
@property (assign, nonatomic) NSInteger flagCount;
@property (strong, nonatomic) NSMutableArray *friends;

@property (strong, nonatomic) LLMyCenterHeadTableViewCell *headCell;

@property (strong, nonatomic) LLUser *user;

@property (strong, nonatomic) LLLoadingView *loadingView;

@property (strong, nonatomic) NSMutableArray *dataObjects;


@property (weak, nonatomic) IBOutlet UIView *messageNotifyView;
@property (weak, nonatomic) IBOutlet UIButton *messageNotifyButton;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;

@property (strong, nonatomic) UIImageView *nRedPoint;

//@property (strong, nonatomic) LLShareExt *shareExt;

@end

@implementation LLMyCenterViewControllerRefactor

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // 接收新评论的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveComment:) name:@"OllaNewCommentNotification" object:nil];// 我的share被点评的推送消息
        // share删除的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareDeleteHandler:) name:@"OllaShareDeleteNotification" object:nil];
        // 录音更新成功的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordUpdateSuccessHandler:) name:@"OllaRecordUpdateSuccessNotification" object:nil];
        
        // 编辑资料更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaHeadPhotoChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaNicknameChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaUsernameChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaGenderChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaCountryChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaSpeakingChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaLearningChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaInterestsChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeadCell:) name:@"OllaCoverPhotoChangeNotification" object:nil];
        
        
        // 移除红点
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isEmailBindNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isBirthBindNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isHomelandBindNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isNativeBindNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isLearningBindNotification" object:nil];
        // detail中进行了点赞或者评论操作的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"LLShareOrPostDetailValueDidChange" object:nil];
        
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:LLPostShareSucceedNotification object:nil];
        
        // @"SynchronizeToMomentNotification"
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"SynchronizeToMomentNotification" object:nil];
        
        // 加入跟离开bar刷新数据
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"LLGroupBarLeaveNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"LLGroupBarJoinNotification" object:nil];
        
        _userInfoDataSource = [NSMutableArray array];
        _notificationMessageDataSource = [NSMutableArray array];
        _shareDataSource = [NSMutableArray array];
        _dataObjects = [NSMutableArray array];
        
        shareDataSource = [[LLShareDataSource alloc] init];
        shareDataSource.delegate = self;
    }
    return self;
}

- (NSMutableArray *)friends {
    if (!_friends) {
        _friends = [NSMutableArray array];
    }
    return _friends;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    userService = [[LLUserService alloc] init];
    
//    // 右上角设置为发送share 
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_share_new"] style:UIBarButtonItemStyleBordered target:self action:@selector(jumpToPostShare)];
    
    // 右上角设置为设置setting
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_setting"] style:UIBarButtonItemStyleBordered target:self action:@selector(settingButtonClick:)];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"me_setting"] forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    rightButton.layer.cornerRadius = 3.f;
    [rightButton addTarget:self action:@selector(settingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.backgroundColor = [UIColor clearColor];
    UIImageView *redPoint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge_number_bg"]];
    self.nRedPoint = redPoint;
//    
//    BOOL isEmail = [[[OllaPreference shareInstance] valueForKey:@"isEmail"] boolValue];
//    BOOL isBirth = [[[OllaPreference shareInstance] valueForKey:@"isBirth"] boolValue];
//    if (isBirth && isEmail) {
//        self.nRedPoint.hidden = YES;
//    }
    
    redPoint.frame = CGRectMake(rightButton.width - 10, 0, 10, 10);
    [rightButton addSubview:redPoint];
    UIBarButtonItem *proe = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = proe;
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RGB_DECIMAL(247, 247, 247);
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // 获取个人信息
    LLUser *user = [userService getMe];
    self.user = user;
    [self.userInfoDataSource removeAllObjects];
    [self.userInfoDataSource addObject:user];
    
    // 添加国旗按钮
    UIImageView *flagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_flag"]];
    flagView.frame = CGRectMake(5, 5, 20, 20);
    flagView.userInteractionEnabled = NO;
//    [self.crownButton addSubview:flagView];
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
    [AppDelegate storyBoradAutoLay:self.loadingView];
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
- (void)loadCacheData {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"pageId"] = @(1);
    params[@"size"] = @(20);
    
    NSArray *cacheArray = [[LLAPICache sharedCache] cacheArrayWithURL:Olla_API_Share_Friends params:params class:[LLShare class] orderBy:@"posttime DESC" limit:20];
    if (cacheArray.count > 0) {
        [self.shareDataSource removeAllObjects];
        [self.shareDataSource addObjectsFromArray:cacheArray];
        [self.tableView reloadData];
    }
}

- (void)loadData {
    
    self.loadingView.page = 1;
    
    __weak __block typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager]
     GETListWithURL:Olla_API_Share_Friends
     parameters:@{@"pageId":@(1),
                  @"size":@(20)}
     modelType:[LLShare class]
     needCache:YES
     success:^(NSArray *datas , BOOL hasNext){
         
         __strong __typeof(self)strongSelf = weakSelf;
         strongSelf.loadingView.hasNext = hasNext;
         if (hasNext) {
             self.loadingView.page += 1;
         }
         
         // 未过滤时用
//         [strongSelf.shareDataSource removeAllObjects];
//         [strongSelf.shareDataSource addObjectsFromArray:datas];
         // 做过滤
         [strongSelf.shareDataSource removeAllObjects];
         strongSelf.shareDataSource = [self dataFilter:datas];
         // *****
         [strongSelf.tableView reloadData];
         
         [strongSelf.tableView.header endRefreshing];
         
         
         
     } failure:^(NSError *error){
//         [self downlinkTaskDidFitalError:error forTaskType:nil];
         
         [weakSelf.tableView.header endRefreshing];
     }];
    
    
    
    
    
}

- (void)loadMoreData {
    
    int page = self.loadingView.page;
    int size = self.loadingView.size;
    NSLog(@"page : %d", page);
    
    [self.loadingView startLoading];
    
    __weak __block typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager]
     GETListWithURL:Olla_API_Share_Friends
     parameters:@{@"pageId":@(page),
                  @"size":@(size)}
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

- (NSMutableArray *)dataFilter:(id)data {
    NSMutableArray *filter = [NSMutableArray array];
    [filter removeAllObjects];
    
    for (LLShare *share in data) {
      //  if (![share.bar.category isEqualToString:@"Chats"]) {
            [filter addObject:share];
        //  }
    }
    
    return filter;
}

- (void)refresh:(id)sender {
    
    if (!userService) {
        userService = [[LLUserService alloc] init];
    }
    LLUser *user = [userService getMe];
    
    [self.userInfoDataSource removeAllObjects];
    [self.userInfoDataSource addObject:user];
    
    [self loadData];
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
     GETListWithURL:Olla_API_Share_Friends
     parameters:@{@"pageId":@(1),
                  @"size":@(20)}
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        if (self.notificationMessageDataSource.count) {  // self.commentNotifyCell  self.notificationMessageDataSource.count
            return 1;
        } else {
            return 0;
        }
    } else {
        return self.shareDataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {  // head cell
        // LLMyCenterHeadTableViewCell
        LLMyCenterHeadTableViewCell *headCell = (LLMyCenterHeadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LLMyCenterHeadTableViewCell"];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLMyCenterHeadTableViewCell" owner:self options:nil];
            headCell = (LLMyCenterHeadTableViewCell *)[nib objectAtIndex:0];
        }
        headCell.user = self.userInfoDataSource[0];
        self.headCell = headCell;
        [headCell.flagButton addSubview:self.flagView];
        
        if (self.flagCount > 0) {
            headCell.flagButton.hidden = NO;
            [headCell.flagButton setTitle:[NSString stringWithFormat:@"  %ld", (long)self.flagCount] forState:UIControlStateNormal];
        } else {
            headCell.flagButton.hidden = YES;
        }
        
        cell = headCell;
    } else if (indexPath.section == 1) {  // notification message
        if (self.notificationMessageDataSource.count) {
            NSDictionary *dataItem = self.notificationMessageDataSource[0];
            [self.commentNotifyCell setDataItem:dataItem];
            self.messageNotifyButton.cornerRadius = self.messageNotifyButton.height / 2.f;
            self.messageNotifyView.cornerRadius = self.messageNotifyView.height / 2.f;
            cell = self.commentNotifyCell;
        }
    } else {  // share cell
        
        LLMyCenterShareTableViewCellRefactor *shareCell = (LLMyCenterShareTableViewCellRefactor *)[tableView dequeueReusableCellWithIdentifier:@"LLMyShareTableController"];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLMyCenterShareTableViewCellRefactor" owner:self options:nil];
            shareCell = (LLMyCenterShareTableViewCellRefactor *)[nib objectAtIndex:0];
        }
        shareCell.dataItem = self.shareDataSource[indexPath.row];
        shareCell.displayLocation = TRUE;
        cell = shareCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        return 305.f;//296.f
    } else if (indexPath.section == 1)
    {
        return 40.f;
    }
    else
    {
        LLMyCenterShareTableViewCellRefactor *shareCell = [[LLMyCenterShareTableViewCellRefactor alloc] init];
        shareCell.displayLocation = TRUE;
        return [shareCell shareCellHeight:self.shareDataSource[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.row == self.shareDataSource.count - 1) && self.loadingView.hasNext) {
        [self loadMoreData];
    }
}

#pragma mark - Record & Play record
- (void)doRecord:(id)sender{
    
//    if ([audioButton.audioPlayer isPlaying]) {
//        [audioButton stop];
//    }
    
    [(UIButton *)sender setEnabled:NO];
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    __block UIImage *blurImage = nil;
    [GCDHelper dispatchBlock:^{
        UIImage *orignalImage = [keyWindow convertToImage];
        blurImage = [orignalImage blurWithLevel:40];
    } completion:^{
//        vpVC  = [[LLVoicePresentationViewController alloc] init];
//        vpVC.uid = self.user.uid;
//        vpVC.blurImage = blurImage;
//        vpVC.view.frame = keyWindow.bounds;
//        [keyWindow addSubview:vpVC.view];
//        
//        [(UIButton *)sender setEnabled:YES];
    }];
}

- (void)playRecord:(id)sender{
    
//    if ([audioButton.audioPlayer isPlaying]) {
//        [audioButton stop];
//        return;
//    }
    
//    audioButton.audioPath = [userService whatsupAudioPath];
//    NSLog(@"whatsupAudioPath:%@", audioButton.audioPath);
//    [audioButton play];
    
}

// 更新button的状态
- (void)recordUpdateSuccessHandler:(NSNotification *)notification{
//    audioButton.enabled = ([[userService whatsupAudioPath] length]!=0);
}

#pragma mark - change cover image
- (void)replaceCover:(id)sender{
    
    if (!imagePickerController) {
        imagePickerController = [[OllaImagePickerController alloc] initWithViewController:self];
        imagePickerController.allowsEditing = YES;
    }
    
    // 选择图片完成时的操作
    __weak typeof(self) weakSelf = self;
    imagePickerController.completeBlock = ^(OllaImagePickerController *controller,UIImage *image){
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateCoverWithImage:image];
    };
    
    // 更换封面选项
    [UIActionSheet showFromTabBar:[self tabbar] withTitle:@"更换朋友圈封面" cancelButtonTitle:@"放弃" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从像册中选择"] tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex){
        
        if (0==tapIndex) {//camera
            //默认 camera
            [imagePickerController setImagePickerType:OllaImagePickerCamera];
            [imagePickerController picker];
            
        }else if(1==tapIndex){// album
            
            [imagePickerController setImagePickerType:OllaImagPickerAlbum];
            [imagePickerController picker];
            
        }// cancel 2
        
    }];
    
    //    [imagePickerController pickerImage];
    
}


- (void) updateAvator:(id)sender{
    
    if (!imagePickerController) {
        imagePickerController = [[OllaImagePickerController alloc] initWithViewController:self];
        imagePickerController.allowsEditing = YES;
    }
    
    // 选择图片完成时的操作
    __weak typeof(self) weakSelf = self;
    imagePickerController.completeBlock = ^(OllaImagePickerController *controller,UIImage *image){
        __strong typeof(self) strongSelf = weakSelf;
       [strongSelf updateAvatorWithImage:image];
    };
    
    // 更换封面选项
    [UIActionSheet showFromTabBar:[self tabbar] withTitle:@"更换个人头像" cancelButtonTitle:@"放弃" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从像册中选择"] tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex){
        
        if (0==tapIndex) {//camera
            //默认 camera
            [imagePickerController setImagePickerType:OllaImagePickerCamera];
            [imagePickerController picker];
            
        }else if(1==tapIndex){// album
            
            [imagePickerController setImagePickerType:OllaImagPickerAlbum];
            [imagePickerController picker];
            
        }// cancel 2
        
    }];
    
    //    [imagePickerController pickerImage];
    
}

- (void)updateAvatorWithImage:(UIImage *)image{
    
    //先设置好封面，再上传
    [self.headCell.coverImageView setImage:image];
    
    // ***** 保存封面图片到本地  以供其他地方使用
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSData *imageData;
    if (UIImagePNGRepresentation(image) == nil) {
        
        imageData = UIImageJPEGRepresentation(image, 100);
        
    } else {
        
        imageData = UIImagePNGRepresentation(image);
        
    }
    [defaults setObject:imageData forKey:@"coverImageData"];
    [defaults synchronize];//用synchronize方法把数据持久化到standardUserDefaults数据库
    
    [userService updateAvatar:image success:^(NSDictionary *userInfo)
     {
        NSString *remoteURL = userInfo[@"data"];//cover
        [[SDImageCache sharedImageCache] storeImage:image forKey:remoteURL];//这里如果能手工建立头像的url缓存，下次进来就不用闪一下了。
        
    }
    fail:^(NSError *error)
     {
        [JDStatusBarNotification showWithStatus:@"封面更新失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        
    }];
}

- (void)updateCoverWithImage:(UIImage *)image{
    
    //先设置好封面，再上传
    [self.headCell.coverImageView setImage:image];
    
    // ***** 保存封面图片到本地  以供其他地方使用
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSData *imageData;
    if (UIImagePNGRepresentation(image) == nil) {
        
        imageData = UIImageJPEGRepresentation(image, 100);
        
    } else {
        
        imageData = UIImagePNGRepresentation(image);
        
    }
    [defaults setObject:imageData forKey:@"coverImageData"];
    [defaults synchronize];//用synchronize方法把数据持久化到standardUserDefaults数据库
    
    [userService updateCover:image success:^(NSDictionary *userInfo) {
        
        NSString *remoteURL = userInfo[@"data"];//cover
        [[SDImageCache sharedImageCache] storeImage:image forKey:remoteURL];//这里如果能手工建立头像的url缓存，下次进来就不用闪一下了。
        
    } fail:^(NSError *error) {
        [JDStatusBarNotification showWithStatus:@"封面更新失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        
    }];
}
- (IBAction)setting:(id)sender
{
    [self openURL:[self.url URLByAppendingPathComponent:@"setting" ] params:nil animated:YES];
}

- (UITabBar *)tabbar{
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
            [self showHint:@"Copy to pasteboard"];
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
        
    } else if ([eventName isEqualToString:LLMyCenterShareCommentClickEvent])
    {  // 点击评论
        // 先判断是否填写资料
        LLShare *dataItem = [userInfo objectForKey:@"dataItem"];
        [self openURL:[self.url URLByAppendingPathComponent:@"share-detail" queryValue:userInfo] params:dataItem animated:YES];
 //       }
        
//        // *****重新获取帖子数据
//        __weak __block typeof(self) weakSelf = self;
//        
//        [[LLHTTPRequestOperationManager shareManager] GETShareDetailWithURL:Olla_API_Share_Detail parameters:@{@"shareId":dataItem.shareId} modelType:[LLShare class] success:^(NSArray *datas, BOOL hasNext) {
//            
//            LLShare *share = [datas objectAtIndex:0];
//            NSDictionary *dict = @{@"showKeyboard":@(1)};
//            
//            if (dataItem.bar) {
//                [weakSelf openURL:[NSURL URLWithString:@"olla:///nav-me/me-refactor/groupbar-post-detail-refactor" queryValue:dict] params:share animated:YES];
//            } else {
//                // share-detail 改 share-detail-refactor
//                [weakSelf openURL:[NSURL URLWithString:@"olla:///nav-me/me-refactor/share-detail-refactor" queryValue:dict] params:share animated:YES];
//            }
//        } failure:^(NSError *error) {
//            
//        }];
    }
    else if ([eventName isEqualToString:LLMyCenterShareBackgroundButtonClickEvent])
    {
        
        // 跳到share详情
        LLShare *dataItem = [userInfo objectForKey:@"share"];
        [self openURL:[self.url URLByAppendingPathComponent:@"share-detail" queryValue:userInfo] params:dataItem animated:YES];
    }
    else if ([eventName isEqualToString:LLMyCenterAvatarButtonClickEvent])
    {  // 点击头像
        [self updateAvator:nil];
    }
    else if ([eventName isEqualToString:LLMyCenterCoverChangeButtonClickEvent])
    {  // 换封面
        [self replaceCover:nil];
    
    }  else if ([eventName isEqualToString:LLMyCenterFavoriteChangeButtonClickEvent]){
        // 跳到收藏列表页面
       // [self openURL:[self.url URLByAppendingPathComponent:@"favorites-list"] animated:YES];
        LLShare *dataItem = [userInfo objectForKey:@"share"];
        [self openURL:[self.url URLByAppendingPathComponent:@"share-detail" queryValue:userInfo] params:dataItem animated:YES];
    }
    else if ([eventName isEqualToString:LLMyCenterShareTapGestureClickEvent])
    {
        // 先判断是否填写资料
        LLShare *dataItem = [userInfo objectForKey:@"share"];
        [self openURL:[self.url URLByAppendingPathComponent:@"share-detail" queryValue:userInfo] params:dataItem animated:YES];
   //     }
    } else if ([eventName isEqualToString:LLMyCenterShareShareButtonClickEvent])
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

- (void)shareNotifyMessagesDidChange:(NSArray *)array {
    self.unreadShareMessages = array;
    if (self.unreadShareMessages.count > 0) {
        LLShareMessage *message = self.unreadShareMessages.firstObject;
//        [_tableController showMessageNotificationWithAvatar:message.user.avatar messageCount:self.unreadShareMessages.count];
        [self showMessageNotificationWithAvatar:message.user.avatar messageCount:self.unreadShareMessages.count];
    }
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
    
    self.hasMessageNotification = YES;
    
//    [self.commentNotifyCell setDataItem:@{@"avatar":[LLAppHelper thumbImageWithURL:avatar size:CGSizeMake(120.f,120.f)], @"message":promptMessage}];
    [self.notificationMessageDataSource removeAllObjects];
    [self.notificationMessageDataSource addObject:@{@"avatar":[LLAppHelper thumbImageWithURL:avatar size:CGSizeMake(120.f,120.f)], @"message":promptMessage}];
    [self.tableView reloadData];
    
}


#pragma mark - News Notify Click
- (IBAction)newsCommentClick:(id)sender {
    
    [self doComment:sender];
}

// 点击新评论通知
- (void)doComment:(id)sender{
    NSArray *messages = [self.unreadShareMessages copy];
    if (messages.count == 1) {
        LLShareMessage *message = messages.firstObject;
        LLShare *share = message.share;
        // share-detail 改 share-detail-refactor
        [self openURL:[NSURL URLWithString:@"olla:///nav-me/me-refactor/share-detail-refactor"] params:share  animated:YES];
        
    } else{//>1 列表
        [self openURL:[NSURL URLWithString:@"olla:///nav-me/me-refactor/share-messages" queryValue:nil]  params:messages animated:YES];
    }
    self.unreadShareMessages = nil;
    [[LLEaseModUtil sharedUtil] removeShareMessages];
//    [_tableController hideMessageNotification];
    [self hideMessageNotification];
}

- (void)hideMessageNotification{
    
//    if ([self.headerCells containsObject:self.commentNotifyCell]) {
//        
//        self.hasMessageNotification = NO;
//        
////        [self.tableView beginUpdates];
////        
////        [self.headerCells removeObject:self.commentNotifyCell];
////        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
////        
////        [self.tableView endUpdates];
//        
//    }
    
    if (self.notificationMessageDataSource.count > 0) {
        
        self.hasMessageNotification = NO;
        [self.notificationMessageDataSource removeAllObjects];
        [self.tableView reloadData];
    }
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

#pragma mark - Red Point
- (void)removeRedPoint {
    
    BOOL isEmail = [[[LLPreference shareInstance] valueForKey:@"isEmail"] boolValue];
    BOOL isBirth = [[[LLPreference shareInstance] valueForKey:@"isBirth"] boolValue];

    
    // self.navigationItem.rightBarButtonItem
    if (isBirth && isEmail) {
//        self.headCell.redPointImageView.hidden = YES;
        self.nRedPoint.hidden = YES;

        if (isBirth) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", self.navigationController.tabBarItem.badgeValue.intValue - 1];
        }

        if (isEmail) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", self.navigationController.tabBarItem.badgeValue.intValue - 1];
        }
        if (self.navigationController.tabBarItem.badgeValue.intValue <= 0) {
            self.navigationController.tabBarItem.badgeValue = nil;
        }

    } else {

        // settingButton添加红点
//        self.headCell.redPointImageView.hidden = NO;
        self.nRedPoint.hidden = NO;
    }
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
