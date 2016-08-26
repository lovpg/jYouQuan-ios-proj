//
//  LLMyCenterViewController.m
//  Olla
//
//  Created by nonstriater on 14-6-22.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLMyCenterViewController.h"
#import "LLHTTPRequestOperationManager.h"
//#import "LLVoicePresentationViewController.h"

#import "LLUser.h"
#import "LLCommentNotify.h"
#import "LLUserDataSource.h"
#import "LLTabbarBadgeController.h"
#import "JDStatusBarNotification.h"
#import "LLUserService.h"
#import "LLOfflineMessageService.h"

//#import "LLCrownViewController.h"
#import "LLSupplyProfileService.h"

//#import "LLAddShareViewController.h"
//#import "LLTranslateViewController.h"

#import "LLShareDataSource.h"
//#import "LLShareMessage.h"

@interface LLMyCenterViewController () <LLShareDataSourceDelegate> {

//    LLVoicePresentationViewController *vpVC;
    
    IBOutlet UIImageView *coverImageView;
    IBOutlet UIButton *headphotoButton; // 更换要用到
    OllaImagePickerController *imagePickerController;
    
    LLUserService *userService;
    LLSupplyProfileService *supplyProfileService;
    
    LLShareDataSource *shareDataSource;
}

@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, strong) LLShare *share;
@property (nonatomic, strong) NSArray *unreadShareMessages;

// 红点
@property (strong, nonatomic) UIImageView *redPointImageView;

@end


@implementation LLMyCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 接收新评论的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveComment:) name:@"OllaNewCommentNotification" object:nil];// 我的share被点评的推送消息
        // share删除的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareDeleteHandler:) name:@"OllaShareDeleteNotification" object:nil];
        // 录音更新成功的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordUpdateSuccessHandler:) name:@"OllaRecordUpdateSuccessNotification" object:nil];
        
        shareDataSource = [[LLShareDataSource alloc] init];
        shareDataSource.delegate = self;
        
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 跳到设置页面
- (void)jumpToSettings:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"setting"]];
    [self openURL:url params:nil animated:YES];
}

// 跳到发表新帖的页面
- (void)jumpToPostShare {
    
    [self openURL:[NSURL URLWithString:@"present:///root/publish"] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   // _tableController = [[LLMyFriendsZoneDataController alloc]init];
    // Do any additional setup after loading the view from its nib
    
//    BOOL isEmail = NO;
//    BOOL isBirth = NO;
//    isEmail = [[[OllaPreference shareInstance] valueForKey:@"isEmail"] boolValue];
//    isBirth = [[[OllaPreference shareInstance] valueForKey:@"isBirth"] boolValue];
//    
//    if (isEmail && isBirth) {
//        // 隐藏红点
//        self.redPointImageView.hidden = YES;
//    } else {
//        // 显示红点
//        if (!self.redPointImageView) {
//            UIImageView *redPointImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.settingButton.bounds)-7, -1, 10, 10)];
//            self.redPointImageView = redPointImageView;
//            redPointImageView.image = [UIImage imageNamed:@"badge_number_bg"];
//            [self.settingButton addSubview:redPointImageView];
//        }
//        self.redPointImageView.hidden = NO;
//        
//    }

    // 右按钮进入设置界面 (修改成发帖按钮)
//    self.navigationItem.rightBarButtonItem = [LLAppHelper barButtonItemWithUserInfo:@"olla:///nav-me/me/setting" imageName:@"setting" target:self action:@selector(doAction:)];
    // 将原来设置按钮改成post share按钮 plaza_topbar_pen
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plaza_topbar_pen"] style:UIBarButtonItemStyleBordered target:self action:@selector(jumpToPostShare)];

//    supplyProfileService = [[LLSupplyProfileService alloc] init];
//    self.navigationItem.rightBarButtonItem = [LLAppHelper barButtonItemWithUserInfo:@"olla:///nav-me/me/setting" imageName:@"setting" target:self action:@selector(doAction:)];

    if (IS_IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    // ***** 更改设置按钮的位置
    [self.settingButton addTarget:self action:@selector(jumpToSettings:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingButton setBackgroundImage:[UIImage imageNamed:@"setting_new"] forState:UIControlStateNormal];
    // settingButton2是一个透明按钮,响应与settingButton同一个事件
    [self.settingButton2 addTarget:self action:@selector(jumpToSettings:) forControlEvents:UIControlEventTouchUpInside];
    // *****
    
    // 添加国旗按钮
    UIImageView *flagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_flag"]];
    flagView.frame = CGRectMake(5, 5, 20, 20);
    flagView.userInteractionEnabled = NO;
    [self.crownButton addSubview:flagView];
    
    NSArray *friends = [LLUser myFriends];
    if (friends.count > 0) {
        NSInteger flagCount = [LLAppHelper flagCountWithFriendList:friends];
        [self.crownButton setTitle:[NSString stringWithFormat:@"  %ld", (long)flagCount] forState:UIControlStateNormal];
    } else {
        [self.crownButton setTitle:@" " forState:UIControlStateNormal];
        self.crownButton.hidden = YES;
        
        __weak __block typeof(self) weakSelf = self;
        
        
//        [[LLFriendsFetcher sharedFetcher] fetchWithSuccess:^(NSArray *array) {
//            NSInteger flagCount = [LLAppHelper flagCountWithFriendList:array];
//            [weakSelf.crownButton setTitle:[NSString stringWithFormat:@"  %lu", (unsigned long)flagCount] forState:UIControlStateNormal];
//            weakSelf.crownButton.hidden = NO;
//        } error:^(NSError *error) {
//            
//        }];
    }
    
    [_tableController reloadData];
    
    // ***** 检测点赞数的增加与减少的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"LikeListDecreased" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"LikeListIncreased" object:nil];
    // *****
}

- (void)refresh:(NSNotification *)notification {
    
    [_tableController reloadData];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isEmailBindNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isBirthBindNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isHomelandBindNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isNativeBindNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:@"isLearningBindNotification" object:nil];

    
    
    userService = [[LLUserService alloc] init];
    self.user  = [userService getMe];
    [self applyDataBinding];
    
    // 录音上传成功以后，要允许点击
//    audioButton.enabled = ([[userService whatsupAudioPath] length]!=0);
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    // ***** 刷新数据
    [self.tableController reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO];
}

- (void)removeRedPoint {
    
    BOOL isEmail = [[[LLPreference shareInstance] valueForKey:@"isEmail"] boolValue];
    BOOL isBirth = [[[LLPreference shareInstance] valueForKey:@"isBirth"] boolValue];
    
    if (isBirth && isEmail) {
        self.redPointImageView.hidden = YES;
        
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
        self.redPointImageView.hidden = NO;
    }
}

// 更新button的状态
- (void)recordUpdateSuccessHandler:(NSNotification *)notification{
//    audioButton.enabled = ([[userService whatsupAudioPath] length]!=0);
}

// 删除帖子时做相关处理
- (void)shareDeleteHandler:(NSNotification *)notification{
    
//    NSString *shareID = [notification.userInfo valueForKey:@"shareId"];
//    [_tableController deleteShare:shareID];
//    [self updateNewComments];
    
}

//这里用到的OllaImagePickerController需要用到路由功能，放在VC中
- (IBAction)replaceCover:(id)sender{

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
    [UIActionSheet showFromTabBar:[self tabbar] withTitle:@"replace cover" cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"camera",@"album"] tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex){
    
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

- (void)updateCoverWithImage:(UIImage *)image{
    
    //先设置好封面，再上传
    [coverImageView setImage:image];
    
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
        [JDStatusBarNotification showWithStatus:@"replace cover fail" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        
    }];
}

- (UITabBar *)tabbar{
    return self.tabBarController.tabBar;
}

// 收到新评论{"cmd":"news","type":"comment","data":uid,shareId,commentId}
- (void)receiveComment:(NSNotification *)notification{
    
//    NSAssert([notification.userInfo isDictionary], @"");
    [self.view setBackgroundColor:[UIColor clearColor]];// 强制loadView
    [shareDataSource loadUnreadNotifyMessages];
}

- (void)shareNotifyMessagesDidChange:(NSArray *)array {
    self.unreadShareMessages = array;
//    if (self.unreadShareMessages.count > 0) {
//        LLShareMessage *message = self.unreadShareMessages.firstObject;
//        [_tableController showMessageNotificationWithAvatar:message.user.avatar messageCount:self.unreadShareMessages.count];
//    }
}

- (void)updateNewComments{
   
    // 消息提醒(用户头像，消息条数)
//    LLCommentNotify * commentNotify = [offlineMessageService lastCommentMessage];
//    if (self) {
//        [[LLEaseModUtil sharedUtil] removeShareMessages];
//        [_tableController hideMessageNotification];
//        [[LLTabbarBadgeController shareController] setTabbarBadgeWithValue:0 atIndex:4];
//        return;
//    }
//    NSString *avatar = [commentNotify comment].user.avatar;
//    if (![avatar isString]) {
//        DDLogError(@"新评论消息，但是avatar wrong %@",avatar);
//        [_tableController hideMessageNotification];
//        return;
//    }
//
    
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
    
//    [_tableController showMessageNotificationWithAvatar:avatar messageCount:commentCounts];
}

//防止双击重复添加崩溃
- (IBAction)doRecord:(id)sender{
    
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
        
         [(UIButton *)sender setEnabled:YES];
    }];
}

- (IBAction)playRecord:(id)sender{

//    if ([audioButton.audioPlayer isPlaying]) {
//        [audioButton stop];
//        return;
//    }
//  
//    audioButton.audioPath = [userService whatsupAudioPath];
//    NSLog(@"whatsupAudioPath:%@", audioButton.audioPath);
//    [audioButton play];
    
}


//点击新评论通知
- (void)doComment:(id)sender{
    NSArray *messages = [self.unreadShareMessages copy];
    if (messages.count == 1) {
//        LLShareMessage *message = messages.firstObject;
//        LLShare *share = message.share;
//        // share-detail 改 share-detail-refactor
//        [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/share-detail-refactor"] params:share  animated:YES];
        
    } else{//>1 列表
        [self openURL:[self.url URLByAppendingPathComponent:@"share-messages" queryValue:nil]  params:messages animated:YES];
    }
    self.unreadShareMessages = nil;
    [[LLEaseModUtil sharedUtil] removeShareMessages];
    [_tableController hideMessageNotification];
}

// 进入国旗墙页面
- (IBAction)crown:(id)sender {
    
    NSDictionary *params = @{@"uid":[[LLPreference shareInstance] uid]};
    
    [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/crown"] params:params animated:YES];
}

//// url route ///////////////////////////////////////////////

- (BOOL)check {
//    if (supplyProfileService.needSupply) {
//        [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
//            
//            if (tapIndex==1) {//OK
//                //[self openURL:[NSURL URLWithString:@"present:///profile-flow/speaking-flow" queryValue:@{@"lang":@"Native"}] animated:YES];
//                [self openURL:[NSURL URLWithString:@"present:///profile-flow/data-perfect"] animated:YES];
//            }
//            
//        }];
//        return NO;
//    }
    return YES;
}

- (BOOL)shouldHandleTableDataController:(OllaController *)controller cell:(OllaTableViewCell *)cell doAction:(id<IOllaAction>)action event:(UIEvent *)event {
    return [self check];
}

//
- (void)tableDataController:(OllaTableDataController *)controller cell:(OllaTableViewCell *)cell doAction:(id<IOllaAction>)action event:(UIEvent *)event{
    
//    if([[action actionName] isEqualToString:@"url-share"]) {
//        [self openURL:[self.url URLByAppendingPathComponent:@"my-share-refactor" queryValue:@{@"uid":self.user.uid}] animated:YES];
//   
//    } else if([[action actionName] isEqualToString:@"comment"]) {
//        
////        // ***** 刷新数据
////        [self.tableController reloadData];
//        // 先判断是否填写资料
////        if ([LLSupplyProfileService sharedService].needSupply) {
////            [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
////                
////                if (tapIndex==1) {//OK
////                    
////                    //[self openURL:[NSURL URLWithString:@"present:///profile-flow/speaking-flow" queryValue:@{@"lang":@"Native"}] animated:YES];
////                    [self openURL:[NSURL URLWithString:@"present:///profile-flow/data-perfect"] animated:YES];
////                }
////                
////            }];
////            return;
////        }
//       
//        //要把整个share数据传递过去
//        LLShare *dataItem = cell.dataItem;
//        NSDictionary *dict = @{@"showKeyboard":@(1)};
//        
//        // *****重新获取帖子数据
//        __weak __block typeof(self) weakSelf = self;
//        
//        [[LLHTTPRequestOperationManager shareManager] GETShareDetailWithURL:Olla_API_Share_Detail parameters:@{@"shareId":dataItem.shareId} modelType:[LLShare class] success:^(NSArray *datas, BOOL hasNext) {
//            
//            for (LLShare *s in datas) {
//                weakSelf.share = s;
//            }
//            
////            if (dataItem.bar) {
////                [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/groupbar-post-detail-refactor" queryValue:dict] params:weakSelf.share animated:YES];
////            } else {
//                // share-detail 改 share-detail-refactor
//                [self openURL:[self.url URLByAppendingPathComponent:@"share-detail" queryValue:dict] params:weakSelf.share animated:YES];
//           // }
//            
//        } failure:^(NSError *error) {
//            
//        }];
//        // *****
//        
////        if (dataItem.bar) {
////            [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/groupbar-post-detail" queryValue:dict] params:dataItem animated:YES];
////        } else {
////            [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/share-detail" queryValue:dict] params:dataItem animated:YES];
////        }
//        
//    }else if([[action actionName] isEqualToString:@"userCenter"]) {
//    
//        // 如果是自己的share，就不应该进 user-center!! 测试下
//        LLShare *dataItem = cell.dataItem;
//        
//        NSMutableDictionary *queryValues = [NSMutableDictionary dictionaryWithDictionary:[dataItem.user dictionaryRepresentation]];
//        [queryValues setValue:@1 forKey:@"flag"];
//        
//        [self openURL:[self.url URLByAppendingPathComponent:@"user-center" queryValue:queryValues] params:coverImageView.image animated:YES];
//        
//    }else if([[action actionName] isEqualToString:@"shareDetail"]) {
    
//        // ***** 刷新数据
//        [self.tableController reloadData];
        
        // 先判断是否填写资料
//        if ([LLSupplyProfileService sharedService].needSupply) {
//            [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
//                
//                if (tapIndex==1) {//OK
//                    
//                    //[self openURL:[NSURL URLWithString:@"present:///profile-flow/speaking-flow" queryValue:@{@"lang":@"Native"}] animated:YES];
//                    [self openURL:[NSURL URLWithString:@"present:///profile-flow/data-perfect"] animated:YES];
//                }
//                
//            }];
//            return;
//        }
//        
        LLShare *dataItem = cell.dataItem;
        
        // *****重新获取帖子数据
        __weak __block typeof(self) weakSelf = self;

        [[LLHTTPRequestOperationManager shareManager] GETShareDetailWithURL:Olla_API_Share_Detail parameters:@{@"shareId":dataItem.shareId} modelType:[LLShare class] success:^(NSArray *datas, BOOL hasNext) {
            
            for (LLShare *s in datas) {
                weakSelf.share = s;
            }
            
//            if (dataItem.bar) {
//                [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/groupbar-post-detail-refactor"] params:weakSelf.share animated:YES];
//            } else {
                // share-detail 改 share-detail-refactor shareDetail
                [self openURL:[self.url URLByAppendingPathComponent:@"share-detail"] params:weakSelf.share animated:YES];
//            }
            
        } failure:^(NSError *error) {
            
        }];
        // *****
        
//        if (dataItem.bar) {
//            [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/groupbar-post-detail"] params:dataItem animated:YES];
//        } else {
//           [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/share-detail"] params:dataItem animated:YES];
//        }
    
//    }
    
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    if ([eventName isEqualToString:@"LLGroupBarDetail"]) {
        LLShare *share = userInfo[@"share"];
//        LLGroupBar *groupBar = share.bar;
//        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"groupbar-detail"]] params:groupBar animated:YES];
    } else if ([eventName isEqualToString:LLShareTextURLClickEvent]) {
        NSURL *url = userInfo[@"url"];
        if (url) {
            if ([url.absoluteString hasPrefix:@"mailto"]) {
                [[UIApplication sharedApplication] openURL:url];
            } else {
                SVWebViewController *webVC = [[SVWebViewController alloc] initWithURL:url];
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
    } else if ([eventName isEqualToString:LLShareTextPhoneNumberClickEvent]) {
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

}


- (void)tableDataController:(OllaController *)controller didSelectAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row < [self.tableController.headerCells count]) {
        return ;
    }
    
    // 先判断是否填写资料
//    if ([LLSupplyProfileService sharedService].needSupply) {
//        [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
//            
//            if (tapIndex==1) {//OK
//                
//                //[self openURL:[NSURL URLWithString:@"present:///profile-flow/speaking-flow" queryValue:@{@"lang":@"Native"}] animated:YES];
//                [self openURL:[NSURL URLWithString:@"present:///profile-flow/data-perfect"] animated:YES];
//            }
//            
//        }];
//        return;
//    }
    
    LLShare *dataItem = [_tableController dataAtIndexRow:indexPath.row];//基类已经处理了headcells
   
//    if (dataItem.bar) {
//        [self openURL:[NSURL URLWithString:@"olla:///nav-me/me/groupbar-post-detail-refactor"] params:dataItem animated:YES];
//    } else {
        // share-detail 改 share-detail-refactor
        [self openURL:[self.url URLByAppendingPathComponent:@"share-detail-refactor"] params:dataItem animated:YES];
 //   }
    
    
}

- (IBAction)backPlaza:(id)sender
{
        [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
