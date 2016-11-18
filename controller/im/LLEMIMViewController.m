//
//  LLEMIMViewController.m
//  Olla
//
//  Created by Pat on 15/3/19.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLEMIMViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "DXFaceView.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "ChatSendHelper.h"
#import "MessageReadManager.h"
#import "MessageModelManager.h"
#import "LocationViewController.h"
#import "UIViewController+HUD.h"
#import "WCAlertView.h"
#import "NSDate+Category.h"
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "CallHelper.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "SVWebViewController.h"
#import "TTGlobalUICommon.h"
#import "GCDObjC.h"
#import "CTAssetsPickerController.h"
#import "LLEaseModUtil.h"
#import "LLUserGuideBrowser.h"
#import "LLFinishQuickTutor.h"

#define kPageCount 20
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height//获取屏幕高度，兼容性测试
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width//获取屏幕宽度，兼容性测试

@interface LLEMIMViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, IChatManagerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate, LocationViewDelegate, EMCDDeviceManagerDelegate,EMCallManagerDelegate, CTAssetsPickerControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_translateMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    dispatch_queue_t _messageQueue;
    
    NSMutableArray *_messages;
    BOOL _isScrollToBottom;
    
    LLUserService *userService;
    
}
@property (nonatomic) BOOL isMoreFloder;
@property (nonatomic) BOOL isChatGroup;
@property (nonatomic) EMConversationType conversationType;
@property (strong, nonatomic) NSString *chatter;
@property (nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIView *moreActionView;
@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic) BOOL isInvisible;
@property (nonatomic) BOOL isKicked;
@property (nonatomic, strong) LLSimpleUser *user;


//气泡view
@property (nonatomic, strong) UIView *popView;
//email
@property (nonatomic, strong) UITextField *emailTF;

@property (nonatomic, strong) NSString *emailFilteredSpace;

@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, strong) UIButton *okBtn;


@end

@implementation LLEMIMViewController


- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageFromNotification:) name:LLEMMessageSendNotification object:nil];
    }
    
    return self;
}



- (IBAction)backAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isChatGroup
{
    return _conversationType != eConversationTypeChat;
}


- (void)viewDidAppear:(BOOL)animated
{

    [CallHelper sharedHelper].isInIMChatView = YES;
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [CallHelper sharedHelper].isInIMChatView = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerBecomeActive];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
//    self.isMoreFloder = false;
//    self.moreActionView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth - 100, 10, 100, 60)];
//    UIImage *blackImage = [UIImage imageNamed:@"black"];
//    UIImageView *blackImageView = [[UIImageView alloc]initWithFrame:CGRectMake(4, 0, 24, 24)];
//    blackImageView.image = blackImage;
//    [self.moreActionView addSubview:blackImageView];
//    UIButton *blackButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
//    blackButton.text = @"屏蔽他";
//    blackButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    blackButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
//    [self.moreActionView addSubview:blackButton];
//    self.moreActionView.backgroundColor = RGB_HEX(0xe21001);
//    [self.view addSubview:self.moreActionView];
//     self.moreActionView.hidden = YES;
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im_bg"]];
//    imageView.frame = self.view.bounds;
//    [self.view addSubview:imageView];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = CGRectMake(0, 0, 32, 32);
    self.indicatorView.center = CGPointMake(self.view.width / 2, self.view.height / 2 - 44);
    self.indicatorView.hidesWhenStopped = YES;
    [self.view addSubview:self.indicatorView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = view;
    
    
    
//    self.navigationItem.rightBarButtonItem = [LLAppHelper barButtonItemWithUserInfo:@"" imageName:@"olla_login_username_h" target:self action:@selector(doAction:)];
    
    
    if (!_conversation)
    {

        self.user = [[self.url queryValue] modelFromDictionaryWithClassName:[LLSimpleUser class]];
        
        _isPlayingAudio = NO;
        _chatter = _user.easeUserName;
        
        _isChatGroup = NO;
        _messages = [NSMutableArray array];
        
        //根据接收者的username获取当前会话的管理者
        
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:_chatter
                                                                    conversationType:_conversationType];
    }
    
    self.title = self.user.nickname;
    self.chatName.text = self.user.nickname;
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    _isScrollToBottom = YES;
    
    [self setupBarButtonItem];
    [self.view addSubview:self.headView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatToolBar];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(handleRefresh)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    _tableView.header = header;
    
    NSString *draftText = [[LLEaseModUtil sharedUtil] chatDraftWithUid:self.user.uid];
    if (draftText.length > 0) {
        self.chatToolBar.text = draftText;
    }
    
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, self.chatToolBar.height, 0);
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]])
    {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
//    _quickTutorStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_quickTutorStopButton setImage:[UIImage imageNamed:@"quick_tutor_stop"]];
//    _quickTutorStopButton.frame = CGRectMake(self.view.width - 60, 15, 45, 45);
//    [_quickTutorStopButton addTarget:self action:@selector(stopQuickTutor) forControlEvents:UIControlEventTouchUpInside];
//    _quickTutorStopButton.hidden = YES;
//    [self.view addSubview:_quickTutorStopButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    
    if ([[LLEaseModUtil sharedUtil] isLoggedIn]) {
        //通过会话管理者获取已收发消息
        long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
        [self loadMoreMessagesFrom:timestamp count:kPageCount append:NO];
    } else {
        __block __weak typeof(self) weakSelf = self;
        self.view.userInteractionEnabled = NO;
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        [self showHudInView:weakSelf.view hint:@"Connecting..."];
        [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed) {
            if (succeed) {
                //通过会话管理者获取已收发消息
                long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
                [weakSelf loadMoreMessagesFrom:timestamp count:kPageCount append:NO];
            } else {
                TTAlertNoTitle(@"Chats unavailable, please try later");
            }
            [weakSelf hideHud];
            weakSelf.view.userInteractionEnabled = YES;
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
    [self updateQuickTutorStatus];
    
#pragma mark -- popView
    //   蒙版  //
    UIView *otherView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    otherView.backgroundColor = [UIColor blackColor];
    otherView.alpha = 0.2f;
    self.shadowView = otherView;
    self.shadowView.hidden = YES;
    [self.view addSubview:otherView];
    //
    
    //弹出气泡
    _popView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, 140)];
    _popView.center=CGPointMake(self.view.width / 2, self.view.height / 2 - 44);

    _popView.backgroundColor=[UIColor whiteColor];
    _popView.cornerRadius=5;
    _popView.userInteractionEnabled=YES;
    [self.view addSubview:_popView];
    _popView.hidden=YES;
    //label
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(27, 21, 172, 21)];
    label.text=@"Please bind the email:";
    [_popView addSubview:label];
    //textField
    _emailTF=[[UITextField alloc]initWithFrame:CGRectMake(27, 52, 192, 35)];
    _emailTF.cornerRadius=5;
    _emailTF.borderWidth=0.1;
    [_popView addSubview:_emailTF];
    //cancel
    UIButton *cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(40, 103, 66, 30)];
    cancelBtn.cornerRadius=5;
    cancelBtn.borderWidth=0.1;
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.textColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    
    [_popView addSubview:cancelBtn];
    //ok
    UIButton *okBtn=[[UIButton alloc]initWithFrame:CGRectMake(140, 103, 66, 30)];
    self.okBtn=okBtn;
    okBtn.cornerRadius=5;
    okBtn.borderWidth=0.1;
    okBtn.textColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    
    [okBtn setTitle:@"OK" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
    [_popView addSubview:okBtn];
    
    
    _emailTF.delegate=self;
    

    
}
#pragma mark -- pop View
//上提动画
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:.5f animations:^{
        self.popView.centerY = self.view.centerY-155;
    }];
    
}



-(void)cancel{
    _emailTF.text=@"";
    _popView.hidden=YES;
    _shadowView.hidden=YES;
    [self.view endEditing:YES];
    _popView.center=CGPointMake(self.view.width / 2, self.view.height / 2 - 44);

}
-(void)ok{
   
    
    //判断邮箱是否为合法

    [self showHudInView:self.view hint:nil];
    
    [self.emailTF resignFirstResponder];
    
    NSString *emailStr = self.emailTF.text;
    
    // 1.过滤空格
    NSString *emailFilterSpace =  [emailStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 2.判断是否为合法邮箱
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isEmailValid = [predicate evaluateWithObject:emailFilterSpace];
    
    self.emailFilteredSpace = emailFilterSpace;
    
    if (isEmailValid) {
       
        
        [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Edit_Email parameters:@{@"email":emailFilterSpace} success:^(id datas, BOOL hasNext) {
            
            [self hideHud];
            
            UIAlertView *linkEmailSuccessAlertView = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Please go to verify email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[userService updateValue:self.emailTF.text forKey:@"email"];
            //弹框提示
            linkEmailSuccessAlertView.tag = 0;
            linkEmailSuccessAlertView.delegate=self;
            [linkEmailSuccessAlertView show];
            _popView.hidden=YES;
            
        } failure:^(NSError *error) {
            
            [self hideHud];
            
            UIAlertView *linkEmailFailureAlertView = [[UIAlertView alloc] initWithTitle:@"Tip" message:[error.userInfo objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            linkEmailFailureAlertView.tag = 1;
            [linkEmailFailureAlertView show];
        }];
    } else {
        // 不合法
        UIAlertView *emailNotValidAlertView = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Please input valid email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        emailNotValidAlertView.tag=2;
        emailNotValidAlertView.delegate = self;
        [emailNotValidAlertView show];
    }
    
    //上传网络
//    __weak typeof(self) weakSelf = self;
//    [userService updateEmail:emailFilterSpace success:^(NSDictionary *userInfo) {
//        //        __strong typeof(self) strongSelf = weakSelf;
//        
//        
//    } fail:^(NSError *error) {
//        [weakSelf hideHud];
//    }];
    
    //_popView.hidden=YES;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
           [self.emailTF resignFirstResponder];
            //[self.emailTF becomeFirstResponder];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"EmailBindAndShowEmailInTheProfile" object:nil userInfo:@{@"email":self.emailFilteredSpace}];
            //            [self openURL:[NSURL URLWithString:@"olla:///nav-me/me-refactor/setting/edit-profile"] animated:YES];
           // [userService updateValue:self.emailTF.text forKey:@"email"];
            _popView.hidden=YES;
            _shadowView.hidden=YES;
            [self hideHud];
        }
        
    } else if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [self.emailTF resignFirstResponder];
          //  [self.emailTF becomeFirstResponder];
           // [[NSNotificationCenter defaultCenter] postNotificationName:@"EmailBindAndShowEmailInTheProfile" object:nil userInfo:@{@"email":self.emailFilteredSpace}];
            //            [self openURL:[NSURL URLWithString:@"olla:///nav-me/me-refactor/setting/edit-profile"] animated:YES];
            //[self successHandler:nil];
        }else if (alertView.tag==2){
            if (buttonIndex == 0) {
                [_emailTF becomeFirstResponder];
                _popView.hidden=NO;
                _shadowView.hidden=NO;
            }
        }
        
    }
}





- (void)handleCallNotification:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        //开始call
        self.isInvisible = YES;
    } else {
        //结束call
        self.isInvisible = NO;
    }
}


- (IBAction)moreAction:(id)sender
{
    [UIActionSheet showInView:[self.presentedViewController view]
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[
                                @"拉黑"]
                     tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex)
     {
         
         if (0==tapIndex)
         {
             [self black:self.user.uid];
         }
         
     }];
}




- (void)setupBarButtonItem
{
    [self.navigationController setNavigationBarHidden:NO];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [backButton setImage:[UIImage imageNamed:@"navigation_back_arrow_new"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [moreButton setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    [self.navigationItem setRightBarButtonItem:moreItem];
//    if (_isChatGroup)
//    {
//        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
//        [detailButton setImage:[UIImage imageNamed:@"group_detail"] forState:UIControlStateNormal];
//        [detailButton addTarget:self action:@selector(showRoomContact:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
//    }
//    else{
//        self.navigationItem.rightBarButtonItem = [LLAppHelper barButtonItemWithUserInfo:@"" imageName:@"nav_more" target:self action:@selector(doAction:)];
//    }
}

- (void)doAction:(id)sender {
    [self gotoProfilePageWithUserInfo:self.user];
}

- (void)gotoProfilePageWithUserInfo:(LLSimpleUser *)userInfo{
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    if (_isScrollToBottom) {
        [self scrollViewToBottom:NO];
    } else{
        _isScrollToBottom = YES;
    }
    self.isInvisible = NO;
    
    
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    
    
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    //    if (_conversation.conversationType == eConversationTypeChatRoom && !_isKicked)
    //    {
    //        //退出聊天室，删除会话
    //        NSString *chatter = [_chatter copy];
    //        [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatter completion:^(EMChatroom *chatroom, EMError *error){
    //            [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatter deleteMessages:YES append2Chat:YES];
    //        }];
    //    }
}
- (IBAction)back:(id)sender
{
    //判断当前会话是否为空，若符合则删除该会话
    EMMessage *message = [_conversation latestMessage];
    if (message == nil) {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
    }
    
    [[LLEaseModUtil sharedUtil] saveChatDraft:self.chatToolBar.inputTextView.text withUid:self.user.uid];
    
    //    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

//- (void)back
//{
//    //判断当前会话是否为空，若符合则删除该会话
//    EMMessage *message = [_conversation latestMessage];
//    if (message == nil) {
//        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
//    }
//    
//    [[LLEaseModUtil sharedUtil] saveChatDraft:self.chatToolBar.inputTextView.text withUid:self.user.uid];
//    
////    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

- (void)setIsInvisible:(BOOL)isInvisible
{
    _isInvisible =isInvisible;
    if (!_isInvisible)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        NSArray *copyMessages = [self.messages copy];
        for (EMMessage *message in copyMessages)
        {
            if ([self shouldAckMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self sendHasReadResponseForMessages:unreadMessages];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}

#pragma mark - Quick Tutor
- (void)updateQuickTutorStatus {
    
//    __block __weak typeof(self) weakSelf = self;
//    [[LLQuickTutorService sharedService] synchronizeWithCompletion:^{
//        weakSelf.quickTutor = [[LLQuickTutorService sharedService] quickTutorWithUid:weakSelf.user.uid];
//        if (weakSelf.quickTutor) {
//            _quickTutorStopButton.hidden = NO;
//        } else {
//            _quickTutorStopButton.hidden = YES;
//        }
//    }];
    
    
}

- (void)stopQuickTutor {
    
//    __block __weak typeof(self) weakSelf = self;
//    
//    PSTAlertController *alertVC = [PSTAlertController alertControllerWithTitle:nil message:@"Are you sure to stop?" preferredStyle:PSTAlertControllerStyleAlert];
//    
//    [alertVC addAction:[PSTAlertAction actionWithTitle:@"NO" handler:^(PSTAlertAction *action) {
//        
//    }]];
//    
//    [alertVC addAction:[PSTAlertAction actionWithTitle:@"OK" handler:^(PSTAlertAction *action) {
//        if (!weakSelf.quickTutor) {
//            weakSelf.quickTutor = [[LLQuickTutorService sharedService] quickTutorWithUid:weakSelf.user.uid];
//        }
//        if (weakSelf.quickTutor) {
//            [weakSelf showHudInView:weakSelf.view hint:nil];
//            NSDictionary *params = @{@"chatId":self.quickTutor.chatId};
//            [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Quick_Tutor_Chat_Finish parameters:params success:^(id datas, BOOL hasNext) {
//                [weakSelf sendQuickTutor:weakSelf.quickTutor type:LLQuickTutorActionTypeFinish];
//                if ([weakSelf.quickTutor.ouid isEqualToString:[OllaPreference shareInstance].uid]) {
//                    NSString *message = [NSString stringWithFormat:@"It's over now, you get %@ coins", weakSelf.quickTutor.coin];
//                    [PSTAlertController showMessage:message];
//                } else {
//                    // 评分前再同步一次
//                    [self updateQuickTutorStatus];
//                    // 评分
//                    if (weakSelf.user && weakSelf.quickTutor) {
//                        NSDictionary *params = @{@"user":weakSelf.user, @"quickTutor":[weakSelf.quickTutor copy]};
//                        [weakSelf openURL:[NSURL URLWithString:[weakSelf.url.urlPath stringByAppendingPathComponent:@"add-evaluation"]] params:params animated:YES];
//                    }
//                }
//                weakSelf.quickTutor = nil;
//                _quickTutorStopButton.hidden = YES;
//                [weakSelf hideHud];
//            } failure:^(NSError *error) {
//                [weakSelf hideHud];
//                [PSTAlertController showMessage:error.localizedDescription];
//            }];
//        }
//    }]];
//    
//    
//
//    [alertVC showWithSender:nil controller:self animated:YES completion:nil];
    
}

#pragma mark - helper
- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

#pragma mark - getter

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (UITableView *)tableView
{
    if (_tableView == nil)
    {

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.chatToolBar.frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
                UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
                lpgr.minimumPressDuration = 0.5;
                [_tableView addGestureRecognizer:lpgr];
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil)
    {
         CGRect frame = [AppDelegate getFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.bounds.size.width, [DXMessageToolBar defaultHeight])];
        
        //CGRect frame = [AppDelegate getFrame:CGRectMake(0,  [DXMessageToolBar defaultHeight], self.view.bounds.size.width, [DXMessageToolBar defaultHeight])];
         NSLog(@"%f,%f,%f",frame.size.width,self.view.bounds.size,ScreenWidth);
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], ScreenWidth, [DXMessageToolBar defaultHeight])];
        
//        CGRect frame = [AppDelegate getFrame:CGRectMake(0, self.view.frame.size.height - [LLPostMessageToolBar defaultHeight], self.view.bounds.size.width, [LLPostMessageToolBar defaultHeight])];
//        //[self.toolBarView setFrame:frame];
//        NSLog(@"%f,,,%f",self.view.bounds.size.width, frame.size.width);
//        self.toolBarView = [[LLPostMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [LLPostMessageToolBar defaultHeight], frame.size.width, [LLPostMessageToolBar defaultHeight])];
//        self.toolBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
//        self.toolBarView.delegate = self;
        
        
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
        
        ChatMoreType type = _isChatGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
        _chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) typw:type];
        _chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin ;
        
    }
    
    return _chatToolBar;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker) {
        _imagePicker.delegate = nil;
        _imagePicker = nil;
    }
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
    _imagePicker.delegate = self;
    
    return _imagePicker;
}

- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}

- (NSDate *)chatTagDate
{
    if (_chatTagDate == nil) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    
    return _chatTagDate;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        } else {
            MessageModel *model = (MessageModel *)obj;
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSDictionary *userInfo = [[[LLPreference shareInstance] userInfo] objectForKey:@"userInfo"];
            NSString *myUrlString = [userInfo objectForKey:@"avatar"];
            NSURL *myHeadURL = [NSURL URLWithString:myUrlString];
            NSURL *friendHeadURL = [NSURL URLWithString:self.user.avatar];
            if (model.isSender) {
                model.headImageURL = myHeadURL;
            } else {
                model.headImageURL = friendHeadURL;
            }
            
            cell.messageModel = model;
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    }
    else{
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

//加载更多
- (void)handleRefresh
{
    _chatTagDate = nil;
    EMMessage *firstMessage = [self.messages firstObject];
    if (firstMessage)
    {
        [self loadMoreMessagesFrom:firstMessage.timestamp count:kPageCount append:YES];
    }
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MessageModel class]]) {
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
        }
    }
}

- (void)reloadData {
    
    _chatTagDate = nil;
    self.dataSource = [[self formatMessages:self.messages] mutableCopy];
    [self.tableView reloadData];
    
    //回到前台时
    if (!self.isInvisible)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        NSArray *copyMessages = [self.messages copy];
        for (EMMessage *message in copyMessages)
        {
            if ([self shouldAckMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self sendHasReadResponseForMessages:unreadMessages];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventLongPressEventName]) {
        UILongPressGestureRecognizer *lgr = [userInfo objectForKey:@"longPressGestureRecognizer"];
        [self handleLongPress:lgr];
    } else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]) {
//        NSMutableDictionary *query = nil;
//        if (model.isSender) {
//            query = [NSMutableDictionary dictionaryWithDictionary:[[OllaPreference shareInstance].userInfo objectForKey:@"userInfo"]];
//        } else {
//            query = [NSMutableDictionary dictionaryWithDictionary:[self.user dictionaryRepresentation]];
//        }
//        
//        if (query.count == 0) {
//            return;
//        }
//        
//        if ([[self.url queryValue][@"flag"] intValue]==1) {
//            //TODO:如果可以从一个内页进入IM，这里就要改了 ==》“olla:///root/tab/im"
//            [query setValue:@(0) forKey:@"flag"];
//            [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
//            
//            
//        }else if([[self.url queryValue][@"flag"] intValue]==0){
//            //从IM回退到user-center
//            [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByReplacingOccurrencesOfString:@"im" withString:@""] queryValue:@{@"flag":@1}] animated:YES];
//        }
    } else if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    }
    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        CGRect startRect = CGRectFromString([userInfo objectForKey:@"startRect"]);
        [self chatImageCellBubblePressed:model startRect:startRect];
    }
    else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
    }
    else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        if ((messageModel.status != eMessageDeliveryState_Failure) && (messageModel.status != eMessageDeliveryState_Pending))
        {
            return;
        }
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
    } else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
        [self chatVideoCellPressed:model];
    } else if([eventName isEqualToString:kRouterEventVoipTapEventName]) {
        [self moreViewAudioCallAction:nil];
    } else if ([eventName isEqualToString:kRouterEventPersonalBubbleTapEventName])
    {
        NSString * ext = [model.message.ext objectForKey:@"ext"];
        NSDictionary *extDic;
        if (! ext || [ext isKindOfClass:[NSString class]])
        {
            extDic = [self dictionaryWithJsonString:(NSString*)ext];
        }
//        EMMessageExtObject *extObject = model.message.extObject;
//        LLShare *share = extObject ? extObject.share : nil;
        NSString *shareId = extDic[@"id"] ? extDic[@"id"]: extDic[@"shareId"] ;
        [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Share_Detail parameters:@{@"shareId":shareId} modelType:[LLShare class]
            success:^(OllaModel *model)
        {
            LLShare *share = (LLShare *)model;
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[share dictionaryRepresentation]];
            [dict setValue:@(1) forKey:@"flag"];
            [dict setValue:share.user.uid forKey:@"uid"];
            [dict setValue:share.user.avatar forKey:@"avatar"];
            [dict setValue:share.user.gender forKey:@"gender"];
            [dict setValue:share.user.nickname forKey:@"nickname"];
            [self openURL:[self.url URLByAppendingPathComponent:@"share-detail" queryValue:dict] params:share  animated:YES];
        }
        failure:^(NSError *error)
         {

        }];

        
    }
        // 如果已经绑定邮箱,则直接显示
        
//        if (!user.email.length) {//未绑定邮箱
//            _popView.hidden=NO;
//            _shadowView.hidden=NO;
//            return;
//
//        }else{



}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil)return nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
//链接被点击
- (void)chatTextCellUrlPressed:(NSURL *)url
{
    if (url) {
        
        if ([url.absoluteString hasPrefix:@"mailto"]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            if ([url.absoluteString isEqualToString:@"http://olla.im/help"]) {
                LLUserGuideBrowser *browser = [[LLUserGuideBrowser alloc] init];
                [self.navigationController pushViewController:browser animated:YES];
            } else if ([url.absoluteString isEqualToString:@"http://olla.im/quick-tutor-rate"]) {
                LLUser *user = [LLPreference shareInstance].user;
                NSDictionary *params = @{@"user":user};
                [self openURL:[self.url URLByAppendingPathComponent:@"evaluation"] params:params animated:YES];
            } else {
                SVWebViewController *webVC = [[SVWebViewController alloc] initWithURL:url];
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
        
    }
}
// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model {
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHint:@"正在下载，请稍侯!"];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        [self showHint:@"正在下载，请稍侯!"];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        //发送已读回执
        if ([self shouldAckMessage:model.message read:YES])
        {
            [self sendHasReadResponseForMessages:@[model.message]];
        }
        __weak typeof(self) weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak typeof(self) weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.chatVoice.localPath completion:^(NSError *error) {
                [weakSelf.messageReadManager stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}
-(void)chatLocationCellBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude) isBarHidden:NO];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)chatVideoCellPressed:(MessageModel *)model{
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.messageBody;
    if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
    {
        NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
        if (localPath && localPath.length > 0)
        {
            [self playVideoWithVideoPath:localPath];
            return;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [weakSelf showHudInView:weakSelf.view hint:@"正在下载视频..."];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }else{
            [weakSelf showHint:@"video for failure!"];
        }
    } onQueue:nil];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    _isScrollToBottom = NO;
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

- (void)showImageWithPath:(NSString *)imagePath startRect:(CGRect)startRect {
    MJPhotoBrowser *photoBrowser = [[MJPhotoBrowser alloc] init];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [NSURL fileURLWithPath:imagePath];
    photo.image = image;
    photo.index = 0;
    photo.startFrame = startRect;
    photoBrowser.photos = @[photo];
    [photoBrowser show];
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model startRect:(CGRect)startRect
{
    __weak typeof(self) weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
                if (localPath && localPath.length > 0) {
                    //                    NSURL *url = [NSURL fileURLWithPath:localPath];
                    //                    self.isScrollToBottom = NO;
                    //                    [self.messageReadManager showBrowserWithImages:@[url]];
                    [self showImageWithPath:localPath startRect:startRect];
                    return ;
                }
            }
            [weakSelf showHudInView:weakSelf.view hint:@"正在下载图片..."];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        //                        NSURL *url = [NSURL fileURLWithPath:localPath];
                        //                        weakSelf.isScrollToBottom = NO;
                        //                        [weakSelf.messageReadManager showBrowserWithImages:@[url]];
                        [self showImageWithPath:localPath startRect:startRect];
                        return ;
                    }
                }
                [weakSelf showHint:@"image for failure!"];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"thumbnail for failure!"];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"thumbnail for failure!"];
                }
            } onQueue:nil];
        }
    }
}

#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    NSArray *dataSource = [self.dataSource copy];
    [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.message.deliveryState = message.deliveryState;
                 *stop = YES;
             }
         }
     }];
    [self.tableView reloadData];
}


- (void)didReceiveHasReadResponse:(EMReceipt *)receipt {
    NSArray *dataSource = [self.dataSource copy];
    [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:receipt.chatId])
             {
                 model.message.isReadAcked = YES;
                 *stop = YES;
             }
         }
     }];
    [self.tableView reloadData];
}

- (void)didReceiveHasDeliveredResponse:(EMReceipt *)receipt {
    NSArray *dataSource = [self.dataSource copy];
    [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:receipt.chatId])
             {
                 model.message.isDeliveredAcked = YES;
                 *stop = YES;
             }
         }
     }];
    [self.tableView reloadData];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMMessage *currMsg = [weakSelf.dataSource objectAtIndex:i];
                    if ([message.messageId isEqualToString:currMsg.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        });
                        
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
    NSLog(@"didFetchingMessageAttachment: %f", progress);
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        
        [self addMessage:message];
        // 如果收到 QuickTutor 回应消息, 则同步 QuickTutor 列表
//        if (message.extType == EMMessageExtTypeQuickTutorRespond) {
//            [self updateQuickTutorStatus];
//            
//            LLQuickTutor *quickTutor = [LLQuickTutor objectWithKeyValues:message.ext];
//            
//            if (self.user && [quickTutor.action isEqualToString:@"finish"] && [quickTutor.uid isEqualToString:[OllaPreference shareInstance].uid]) {
//                
//                [[GCDQueue mainQueue] queueBlock:^{
//                    NSDictionary *params = @{@"user":self.user, @"quickTutor":[quickTutor copy]};
//                    [self openURL:[NSURL URLWithString:[self.url.urlPath stringByAppendingPathComponent:@"add-evaluation"]] params:params animated:YES];
//                    [PSTAlertController showMessage:@"Tutor finish"];
//                }];
//            }
//        }
        if ([self shouldAckMessage:message read:NO])
        {
            [self sendHasReadResponseForMessages:@[message]];
        }
        if ([self shouldMarkMessageAsRead])
        {
            [self markMessagesAsRead:@[message]];
        }
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
//        [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
    }
}

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [_conversation.chatter isEqualToString:conversationChatter]) {
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(_messageQueue, ^{
            for (int i = 0; i < self.dataSource.count; i ++) {
                id object = [self.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    MessageModel *currentModel = [self.dataSource objectAtIndex:i];
                    EMMessage *currMsg = [currentModel message];
                    if ([messageId isEqualToString:currMsg.messageId]) {
                        currMsg.deliveryState = eMessageDeliveryState_Failure;
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:currMsg];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        });
                        
                        break;
                    }
                }
            }
        });
    
    }
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
    if ([self shouldMarkMessageAsRead])
    {
        [_conversation markAllMessagesAsRead:YES];
    }
    if (![offlineMessages count])
    {
        return;
    }
    _chatTagDate = nil;
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:[self.messages count] + [offlineMessages count] append:NO];
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    if (_isChatGroup && [group.groupId isEqualToString:_chatter]) {
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didInterruptionRecordAudio
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    
    [self stopAudioPlayingWithChangeCategory:YES];
}

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error
{
    if (!error && _isChatGroup && [_chatter isEqualToString:group.groupId])
    {
        self.title = group.groupSubject;
    }
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    CTAssetsPickerController *imagePicker = [[CTAssetsPickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:NULL];
    //    UIImagePickerController *imagePicker = [self imagePicker];
    //    // 弹出照片选择
    //    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    //    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView
{
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:@"simulator does not support taking picture"];
#elif TARGET_OS_IPHONE
    
    UIImagePickerController *imagePicker = [self imagePicker];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView{
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:@"simulator does not support video"];
#elif TARGET_OS_IPHONE
    UIImagePickerController *imagePicker = [self imagePicker];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    [self presentViewController:imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter" object:self.chatter];

}

- (void)moreViewTranslateAction:(DXChatBarMoreView *)moreView {
//    LLTranslateViewController *translateVC = [[LLTranslateViewController alloc] init];
//    translateVC.editable = YES;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:translateVC];
//    [self presentViewController:nav animated:YES completion:nil];

}

- (void)moreViewQuickTutorAction:(DXChatBarMoreView *)moreView {
    
//    if (self.quickTutor) {
//         
//        __block __weak typeof(self) weakSelf = self;
//        
//        PSTAlertController *alertVC = [PSTAlertController alertControllerWithTitle:nil message:@"You must stop current quick tutor first" preferredStyle:PSTAlertControllerStyleAlert];
//        
//        [alertVC addAction:[PSTAlertAction actionWithTitle:@"NO" handler:^(PSTAlertAction *action) {
//            
//        }]];
//        
//        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Stop" handler:^(PSTAlertAction *action) {
//            [weakSelf stopQuickTutor];
//        }]];
//        
//        return;
//    }
//    
//    [self openURL:[NSURL URLWithString:[self.url.urlPath stringByAppendingPathComponent:@"chat-quick-tutor"]] params:self.user animated:YES];
}

#pragma mark - LocationViewDelegate

-(void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
    EMMessage *locationMessage = [ChatSendHelper sendLocationLatitude:latitude longitude:longitude address:address toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO ext:nil];
    [self addMessage:locationMessage];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, toHeight, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, toHeight, 0);
    }];
    [self scrollViewToBottom:YES];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
        [[LLEaseModUtil sharedUtil] saveChatDraft:nil withUid:self.user.uid];
    }
}

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
        
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName
                                                                 completion:^(NSError *error)
         {
             if (error) {
                 NSLog(@"%@",error);
             }
         }];
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath
                                                       displayName:@"audio"];
            voice.duration = aDuration;
            
            [weakSelf sendAudioMessage:voice];
        }else {
            [weakSelf showHudInView:self.view hint:@"录音太短."];
            weakSelf.chatToolBar.recordButton.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
                weakSelf.chatToolBar.recordButton.enabled = YES;
            });
        }
    }];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
        [self sendVideoMessage:chatVideo];
        
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self sendImageMessage:orgImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker dismissViewControllerAnimated:YES completion:^(){
        [[GCDQueue highPriorityGlobalQueue] queueBlock:^{
            for (ALAsset *asset in assets) {
                sleep(0.5);
                UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                [self sendImageMessage:image];
                sleep(1);
            }
        }];
        
    }];
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    
    _longPressIndexPath = nil;
}

- (void)translateMenuAction:(id)sender {
//    if (_longPressIndexPath.row > 0) {
//        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
//        LLTranslateViewController *translateVC = [[LLTranslateViewController alloc] init];
//        translateVC.sourceText = model.content;
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:translateVC];
//        [self presentViewController:nav animated:YES completion:nil];
//    }
//    
//    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
        [_conversation removeMessage:model.message];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
        if (_longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:_longPressIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(_messageQueue, ^{
            [weakSelf.dataSource removeObjectsAtIndexes:indexs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            });

        });
        
        
    }
    
    _longPressIndexPath = nil;
}

#pragma mark - private

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


- (void)stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    MessageModel *playingModel = [self.messageReadManager stopMessageAudioModel];
    NSIndexPath *indexPath = nil;
    if (playingModel) {
        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    }
    
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
}


- (void)sendReadResponse {
    
    for (id obj in self.dataSource) {
        if ([obj isKindOfClass:[MessageModel class]]) {
            MessageModel *messageModel = (MessageModel *)obj;
            if (!messageModel.isSender && !messageModel.message.isRead) {
                [[EaseMob sharedInstance].chatManager sendReadAckForMessage:messageModel.message];
            }
        }
    }
    
}


- (void)loadMoreMessagesFrom:(long long)timestamp count:(NSInteger)count append:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:count before:timestamp];
        if ([messages count] > 0) {
            NSInteger currentCount = 0;
            if (append)
            {
                [weakSelf.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                NSArray *formated = [weakSelf formatMessages:messages];
                id model = [weakSelf.dataSource firstObject];
                if ([model isKindOfClass:[NSString class]])
                {
                    NSString *timestamp = model;
                    [formated enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                        if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                        {
                            [weakSelf.dataSource removeObjectAtIndex:0];
                            *stop = YES;
                        }
                    }];
                }
                currentCount = [weakSelf.dataSource count];
                [weakSelf.dataSource insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                EMMessage *latest = [weakSelf.messages lastObject];
                weakSelf.chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)latest.timestamp];
            } else
            {
                weakSelf.messages = [messages mutableCopy];
                weakSelf.dataSource = [[weakSelf formatMessages:messages] mutableCopy];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
                [weakSelf.tableView.header endRefreshing];
            });
            
            //从数据库导入时重新下载没有下载成功的附件
            for (EMMessage *message in messages)
            {
                [weakSelf downloadMessageAttachments:message];
            }
            
            NSMutableArray *unreadMessages = [NSMutableArray array];
            for (NSInteger i = 0; i < [messages count]; i++)
            {
                EMMessage *message = messages[i];
                if ([self shouldAckMessage:message read:NO])
                {
                    [unreadMessages addObject:message];
                }
            }
            if ([unreadMessages count])
            {
                [self sendHasReadResponseForMessages:unreadMessages];
            }
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView.header endRefreshing];
                weakSelf.tableView.header = nil;
            });
            
        }
    });
}

- (void)downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:@"thumbnail for failure!"];
        }
    };
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    if ([messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Video)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Voice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.attachmentDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载语言
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
        }
    }
}

- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    NSMutableArray *formatArray = [[NSMutableArray alloc] init];
    if ([messagesArray count] > 0) {
        for (EMMessage *message in messagesArray) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [formatArray addObject:[createDate formattedTime]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            
            if (model) {
                NSDictionary *userInfo = [[[LLPreference shareInstance] userInfo] objectForKey:@"userInfo"];
                NSString *myUrlString = [userInfo objectForKey:@"avatar"];
                NSURL *myHeadURL = [NSURL URLWithString:myUrlString];
                NSURL *friendHeadURL = [NSURL URLWithString:self.user.avatar];
                if (model.isSender) {
                    model.headImageURL = myHeadURL;
                } else {
                    model.headImageURL = friendHeadURL;
                }
                //model.nickName = @"";
                [formatArray addObject:model];
            }
        }
    }
    
    return formatArray;
}

-(NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    
    if (model) {
        NSDictionary *userInfo = [[[LLPreference shareInstance] userInfo] objectForKey:@"userInfo"];
        NSString *myUrlString = [userInfo objectForKey:@"avatar"];
        NSURL *myHeadURL = [NSURL URLWithString:myUrlString];
        NSURL *friendHeadURL = [NSURL URLWithString:self.user.avatar];
        if (model.isSender) {
            model.headImageURL = myHeadURL;
        } else {
            model.headImageURL = friendHeadURL;
        }
        //model.nickName = @"";
        [ret addObject:model];
    }
    
    return ret;
}

-(void)addMessage:(EMMessage *)message
{
    [_messages addObject:message];
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

- (void)scrollViewToBottom:(BOOL)animated
{
//    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
//    {
//        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
//        [self.tableView setContentOffset:offset animated:animated];
//    }
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    if (rows > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)showRoomContact:(id)sender
{
    [self.view endEditing:YES];
    if (_isChatGroup) {
//        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:_chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
    }
}
// 举报
- (IBAction)black:(id)sender
{
    
    [UIAlertView showWithTitle:nil message:@"拉入黑名单，将不能和你互动!" cancelButtonTitle:@"放弃" otherButtonTitles:@[@"拉黑"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex)
    {
        if (tapIndex==1)
        {// 确定拉黑
            
            // 防止多次点击
            if (_isLoading)
            {
                return;
            }
            _isLoading = YES;
            MBProgressHUD *hud = [[MBProgressHUD alloc] init];
            hud.labelText = @"正在提交请求...";
            [self.view addSubview:hud];
            [hud show:YES];
            NSString *uid = self.user.uid;
            NSString *easeUsername = [NSString stringWithFormat:@"%@", uid];
            __weak typeof(self) weakSelf = self;
            [[LLHTTPRequestOperationManager shareManager]
             GETWithURL:TM_API_Black_Add
             parameters:@{
                          @"uid":uid
                          }
            success:^(id datas,BOOL hasNext)
            {
                 
                 [[EaseMob sharedInstance].chatManager blockBuddy:easeUsername relationship:eRelationshipFrom];
                 __strong typeof (self)strongSelf = weakSelf;
                 strongSelf.isLoading = NO;
                 [hud removeFromSuperview];
                 [self blackPeopleSuccessHandler];
                 
             }
             failure:^(NSError *error)
            {
                 weakSelf.isLoading = NO;
                 //TODO: 拉黑失败
                 DDLogError(@"拉黑失败：%@",error);
                 [hud removeFromSuperview];
                 
                 [self blackPeopleFailuerHandler];
                 
             }];
            
            
        }
        
    }];
    
}
- (void)blackPeopleSuccessHandler
{
    
    // 取消关注，从朋友数据库中移除
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaBlackSomeOneNotification" object:nil userInfo:[self.url queryValue]];
    
    MBProgressHUD *completeHUD = [[MBProgressHUD alloc] init];
    completeHUD.labelText = @"拉黑成功";
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"complete"]];
    completeHUD.customView = imageView;
    completeHUD.mode = MBProgressHUDModeCustomView;
    [self.view addSubview:completeHUD];
    [completeHUD show:YES];
    [completeHUD hide:YES afterDelay:1.0];
    // 举报后  发送unfollow请求
    [userService unfollow:self.user];
    
}


- (void)blackPeopleFailuerHandler
{
    
}
- (void)removeAllMessages:(id)sender
{
    if (_dataSource.count == 0) {
        [self showHint:@"所有信息已清除"];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        if (self.isChatGroup && [groupId isEqualToString:_conversation.chatter]) {
            [_conversation removeAllMessages];
            [_messages removeAllObjects];
            _chatTagDate = nil;
            [_dataSource removeAllObjects];
            [_tableView reloadData];
            [self showHint:@"所有信息已清除"];
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        [WCAlertView showAlertWithTitle:nil
                                message:@"确定要删除吗？"
                     customizationBlock:^(WCAlertView *alertView) {
                         
                     } completionBlock:
         ^(NSUInteger buttonIndex, WCAlertView *alertView) {
             if (buttonIndex == 1) {
                 [weakSelf.conversation removeAllMessages];
                 [weakSelf.messages removeAllObjects];
                 weakSelf.chatTagDate = nil;
                 [weakSelf.dataSource removeAllObjects];
                 [weakSelf.tableView reloadData];
             }
         } cancelButtonTitle:@"放弃"
                      otherButtonTitles:@"删除", nil];
    }
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (_translateMenuItem == nil) {
        _translateMenuItem = [[UIMenuItem alloc] initWithTitle:@"翻译" action:@selector(translateMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == eMessageBodyType_Text) {
        if ([showInView isKindOfClass:[EMChatTextBubbleView class]]) {
            [_menuController setMenuItems:@[_copyMenuItem, _translateMenuItem, _deleteMenuItem]];
        } else {
            [_menuController setMenuItems:@[_deleteMenuItem]];
        }
    } else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self didReceiveMessage:message];
    }
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
}

- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)shouldMarkMessageAsRead
{
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
    {
        return NO;
    }
    
    return YES;
}


- (void)sendHasReadResponseForMessages:(NSArray*)messages
{
    dispatch_async(_messageQueue, ^{
        NSArray *copyMessages = [messages copy];
        for (EMMessage *message in copyMessages)
        {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
        }
    });
}

- (void)markMessagesAsRead:(NSArray*)messages
{
    EMConversation *conversation = _conversation;
    dispatch_async(_messageQueue, ^{
        NSArray *copyMessages = [messages copy];
        for (EMMessage *message in copyMessages)
        {
            [conversation markMessageWithId:message.messageId asRead:YES];
        }
    });
}



- (EMMessageType)messageType
{
    EMMessageType type = eMessageTypeChat;
    switch (_conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}


#pragma mark - send message


-(void)sendTextMessage:(NSString *)textMessage
{
    if (![[LLEaseModUtil sharedUtil] isLoggedIn]) {
        [self showHudInView:self.view hint:@"Connecting..."];
        __block __weak typeof(self) weakSelf = self;
        [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed) {
            if (succeed) {
                [weakSelf sendTextMessage:textMessage];
            } else {
                TTAlertNoTitle(@"Chats unavailable, please try later");
            }
            [weakSelf hideHud];
        }];
        return;
    }
    
    if (textMessage.length > 1000) {
        textMessage = [textMessage substringToIndex:1000];
    }
    
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage
                                                            toUsername:_conversation.chatter
                                                           isChatGroup:_isChatGroup
                                                     requireEncryption:NO
                                                                   ext:nil];
    [self addMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)imageMessage
{
    
    if (![[LLEaseModUtil sharedUtil] isLoggedIn]) {
        [self showHudInView:self.view hint:@"Connecting..."];
        __block __weak typeof(self) weakSelf = self;
        [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed) {
            if (succeed) {
                [weakSelf sendImageMessage:imageMessage];
            } else {
                TTAlertNoTitle(@"Chats unavailable, please try later");
            }
            [weakSelf hideHud];
        }];
        return;
    }
    
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:imageMessage
                                                            toUsername:_conversation.chatter
                                                           isChatGroup:_isChatGroup
                                                     requireEncryption:NO
                                                                   ext:nil];
    [self addMessage:tempMessage];
}

-(void)sendAudioMessage:(EMChatVoice *)voice
{
    if (![[LLEaseModUtil sharedUtil] isLoggedIn]) {
        [self showHudInView:self.view hint:@"Connecting..."];
        __block __weak typeof(self) weakSelf = self;
        [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed) {
            if (succeed) {
                [weakSelf sendAudioMessage:voice];
            } else {
                TTAlertNoTitle(@"Chats unavailable, please try later");
            }
            [weakSelf hideHud];
        }];
        return;
    }
    
    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice
                                            toUsername:_conversation.chatter
                                           isChatGroup:_isChatGroup
                                     requireEncryption:NO ext:nil];
    [self addMessage:tempMessage];
}

-(void)sendVideoMessage:(EMChatVideo *)video
{
    if (![[LLEaseModUtil sharedUtil] isLoggedIn]) {
        [self showHudInView:self.view hint:@"Connecting..."];
        __block __weak typeof(self) weakSelf = self;
        [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed) {
            if (succeed) {
                [weakSelf sendVideoMessage:video];
            } else {
                TTAlertNoTitle(@"Chats unavailable, please try later");
            }
            [weakSelf hideHud];
        }];
        return;
    }
    
    EMMessage *tempMessage = [ChatSendHelper sendVideo:video
                                            toUsername:_conversation.chatter
                                           isChatGroup:_isChatGroup
                                     requireEncryption:NO ext:nil];
    [self addMessage:tempMessage];
}


//- (void)sendQuickTutor:(LLQuickTutor *)quickTutor type:(LLQuickTutorActionType)type {
//    
//    if (![[LLEaseModUtil sharedUtil] isLoggedIn]) {
//        [self showHudInView:self.view hint:@"Connecting..."];
//        __block __weak typeof(self) weakSelf = self;
//        [[LLEaseModUtil sharedUtil] loginWithCompletion:^(BOOL succeed) {
//            if (succeed) {
//                [weakSelf sendQuickTutor:quickTutor type:type];
//            } else {
//                TTAlertNoTitle(@"Chats unavailable, please try later");
//            }
//            [weakSelf hideHud];
//        }];
//        return;
//    }
//    
//    NSString *sendString = nil;
//    NSString *actionString = nil;
//    
//    switch (type) {
//        case LLQuickTutorActionTypeCancel:
//            sendString = @"Tutor cancelled";
//            actionString = @"cancel";
//            break;
//        case LLQuickTutorActionTypeAccept:
//            sendString = @"Tutor begin";
//            actionString = @"accept";
//            break;
//        case LLQuickTutorActionTypeReject:
//            sendString = @"Tutor refused";
//            actionString = @"reject";
//            break;
//        case LLQuickTutorActionTypeFinish:
//            sendString = @"Tutor finish";
//            actionString = @"finish";
//            break;
//        case LLQuickTutorActionTypeTips:
//            sendString = @"Tutor tips";
//            actionString = @"tips";
//        default:
//            break;
//    }
//    
//    if (sendString.length == 0 || actionString.length == 0) {
//        return;
//    }
//    
//    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
//    ext[@"type"] = @"quicktutor";
//    ext[@"action"] = actionString;
//    ext[@"uid"] = quickTutor.uid;
//    ext[@"ouid"] = quickTutor.ouid;
//    ext[@"language"] = quickTutor.lang.capitalizedString;
//    ext[@"coin"] = quickTutor.coin;
//    ext[@"chatId"] = quickTutor.chatId;
//    
//    EMMessage *message = [ChatSendHelper sendTextMessageWithString:sendString
//                                   toUsername:_conversation.chatter
//                                  isChatGroup:_isChatGroup
//                            requireEncryption:NO
//                                          ext:ext];
//    
//    [self addMessage:message];
//}


- (void)sendMessageFromNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[EMMessage class]]) {
        EMMessage *message = notification.object;
        [self addMessage:message];
    }
    [self.tableView reloadData];
}

#pragma mark - EMDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_isPlayingAudio) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - ICallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error
{
    if (reason == eCallReasonNull) {
        if ([[EMCDDeviceManager sharedInstance] isPlaying]) {
            [self stopAudioPlayingWithChangeCategory:NO];
        }
    }
}

- (void)registerBecomeActive{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didBecomeActive{
    [self reloadData];
}

@end
