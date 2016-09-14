//
//  LLShell.m
//  Olla
//
//  Created by nonstriater on 14-6-23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

/*
 1) 微博，微信等三方
 2）远程消息处理
 3） 静默推送/下载处理
 */

#import "LLShell.h"
#import "LLHTTPRequestOperationManager.h"
#import "TTGlobalUICommon.h"
#import "LLHTTPRequestOperationManager.h"
#import "LLMemoryInfoCenter.h"


static NSString *umengAppKey = @"547c2d92fd98c56fb6000631";

@implementation LLShell

- (id)init
{
    if (self=[super initWithConfig:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]] bundle:nil])
    {
        
    }
    signupService = [[LLSignupService alloc]init];
    userService = [[LLUserService alloc]init];
    loginService = [[LLLoginService alloc]init];
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [LLAppHelper resetHTTPSTestEnv];

//    [MobClick startWithAppkey:umengAppKey reportPolicy:BATCH channelId:nil];
//#ifdef DEBUG
//    [MobClick setCrashReportEnabled:NO];
//#else
//    [MobClick setCrashReportEnabled:YES];
//#endif
    
    //VOIP设置 最短600s        
    _connectionState = eEMConnectionConnected;
    
    [self registerRemoteNotification];
    
    NSString *apnsCertName = nil;
    #if DEBUG
        apnsCertName = @"apns_dev_strongarm";
    #else
        apnsCertName = @"apns_prod_strongarm";
    #endif
    NSString *easeKey = nil;
    if ([LLAppHelper isTestEnv]) {
        easeKey = @"lbslm#strongarm";
    } else {
        easeKey = @"lbslm#strongarm";
    }
    NSLog(@"%@",  [EaseMob sharedInstance].sdkVersion);
    
    [[EaseMob sharedInstance] registerSDKWithAppKey:easeKey
                                       apnsCertName:apnsCertName
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];

    
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:NO];
    [[EaseMob sharedInstance].chatManager enableDeliveryNotification];
    // 注册环信监听
    [self registerEaseMobNotification];
    [[EaseMob sharedInstance] application:application
            didFinishLaunchingWithOptions:launchOptions];
    
    [self setupNotifiers];
    
    // 关闭默认解压
    [SDImageCache sharedImageCache].shouldDecompressImages = NO;
    
//    //umeng
//    [UMSocialData setAppKey:umengAppKey];
//    [UMSocialWechatHandler setWXAppId:@"wxaba4a6b1f0b51b55" appSecret:@"d4ade75157d8e9dae56accf290200b17" url:Olla_APP_STORE_URL];
//    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
//    //[UMSocialFacebookHandler setFacebookAppID:@"1504817319776427" shareFacebookWithURL:appStoreDownloadURL];
//    
//    [UMSocialTwitterHandler openTwitter];//打开Twitter
    
    [self.window makeKeyAndVisible];// 之前没有这句

#if !Olla_Production
    if ([LLAppHelper showDevUsage]) {
        [[LLMemoryInfoCenter defaultCenter] showMemoryUsage];
    }
#endif
    
    if (launchOptions) {
        NSDictionary*userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if(userInfo)
        {
            [self didReiveceRemoteNotification:userInfo];
        }
    }
//    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];

    return YES;
    
//    [MobClick checkUpdate:@"New version" cancelButtonTitle:@"Skip" otherButtonTitles:@"Update"];
//    
//    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    DDLogInfo(@"app did enter background ");
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}


// 电话，锁屏会受到，可以做关闭网络，保存数据工作
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

// 可以用之前的数据恢复app， didfinishlaunch之后也会调用这个方法，注意区分复原和启动
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 三方平台打开
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
//    return [UMSocialSnsService handleOpenURL:url];
    return true;
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
//    
//    if([[url absoluteString] isEqualToString:@"fb1504817319776427"]) {
//        BOOL urlWasHandled =
//        [FBAppCall handleOpenURL:url
//               sourceApplication:sourceApplication
//                 fallbackHandler:
//         ^(FBAppCall *call) {
//             // Parse the incoming URL to look for a target_url parameter
//             NSString *query = [url query];
//             NSDictionary *params = [self parseURLParams:query];
//             // Check if target URL exists
//             NSString *appLinkDataString = [params valueForKey:@"al_applink_data"];
//             if (appLinkDataString) {
//                 NSError *error = nil;
//                 NSDictionary *applinkData =
//                 [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding]
//                                                 options:0
//                                                   error:&error];
//                 if (!error &&
//                     [applinkData isKindOfClass:[NSDictionary class]] &&
//                     applinkData[@"target_url"]) {
//                     self.refererAppLink = applinkData[@"referer_app_link"];
//                     NSString *targetURLString = applinkData[@"target_url"];
//                     // Show the incoming link in an alert
//                     // Your code to direct the user to the
//                     // appropriate flow within your app goes here
//                     [[[UIAlertView alloc] initWithTitle:@"Received link:"
//                                                 message:targetURLString
//                                                delegate:nil
//                                       cancelButtonTitle:@"OK"
//                                       otherButtonTitles:nil] show];
//                 }
//             }
//         }];
//        
//        return urlWasHandled;
//
//    }
//    
//    return [UMSocialSnsService handleOpenURL:url];
    return true;
}


// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

//for iOS8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [application registerForRemoteNotifications];
}

// ///////////////////////////////////////////////////////
/**
 *  1. 获得device token,http post发送给我们的服务器，苹果不保证device token不变，靠谱的做法是：在本地保存一份，每次比较，如果有变化，就通知我们的服务器更新记录
 *  2。 uiapplication registerForRemoteNotificationTypes：
 *  3. 推送profile 交给服务器
 *
 *  服务端：
 *  1. device token表
 *  2. 遍历device token表，发送消息
 *  gateway.push.apple.com 2195
 *  300万机器 8台服务器 5分钟发完
 */


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *localDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.lbslm.deviceToken"];
    //NSString *tokenString = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding]; // 这个会的得到nil的结果
    //NSString *tokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];//保留空格！
    NSString *tokenString = [[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    DDLogInfo(@"token == %@ ",tokenString);
    if (![localDeviceToken isEqualToString:tokenString])
    {// 发给服务器
        [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"com.lbslm.deviceToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([self.uid length])
        {
            [self sendDeviceToken:tokenString];
        }
        
    }
    
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}




- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DDLogError(@"get apns token error,%@",error);
    TTAlert(error.description);
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];

}

- (void)sendDeviceToken:(NSString *)token{
    
    if (!token) {
        DDLogError(@"get apns token nil");
        return;
    }
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_DeviceToken
     parameters:@{@"token":token}
     success:^(id datas, BOOL hasNext){
        
    } failure:^(NSError *error){
        //TODO:10 如果失败，应该在网络恢复时，重新再传一次
        DDLogError(@"API TOKEN fail:%@",error);
    }];

}



// 在前台时可以再这里收到推送消息，进入后台后不能
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
#if DEBUG
    NSString *message = userInfo[@"aps"][@"alert"];
    if ([message length]) {
        UILocalNotification *ln = [[UILocalNotification alloc] init];
        ln.alertBody = message;
        [application scheduleLocalNotification:ln];
    }
#endif
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{

}




// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - notifiers
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}


// 注册推送
- (void)registerRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    } else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}



#pragma mark - IChatManagerDelegate
// 开始自动登录回调
-(void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{

}

// 结束自动登录回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
}

// 好友申请回调
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    if (!username) {
        return;
    }
    if (!message) {
        message = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), username];
    }
    //    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":username, @"username":username, @"applyMessage":message, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleFriend]}];
    //    [[ApplyViewController shareController] addNewApply:dic];
    //    if (self.mainController) {
    //        [self.mainController setupUntreatedApplyCount];
    //    }
}

// 离开群组回调
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSString *tmpStr = group.groupSubject;
    NSString *str;
    if (!tmpStr || tmpStr.length == 0) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *obj in groupArray) {
            if ([obj.groupId isEqualToString:group.groupId]) {
                tmpStr = obj.groupSubject;
                break;
            }
        }
    }
    
    if (reason == eGroupLeaveReason_BeRemoved) {
        str = [NSString stringWithFormat:NSLocalizedString(@"group.beKicked", @"you have been kicked out from the group of \'%@\'"), tmpStr];
    }
    if (str.length > 0) {
        //        TTAlertNoTitle(str);
    }
}

// 申请加入群组被拒绝回调
- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason
                                       error:(EMError *)error{
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), groupname];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:reason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!groupId || !username) {
        return;
    }
    
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), username, groupname];
    }
    else{
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), username, groupname, reason];
    }
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.sendApplyFail", @"send application failure:%@\nreason：%@"), reason, error.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        //        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":groupname, @"groupId":groupId, @"username":username, @"groupname":groupname, @"applyMessage":reason, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleJoinGroup]}];
        //        [[ApplyViewController shareController] addNewApply:dic];
        //        if (self.mainController) {
        //            [self.mainController setupUntreatedApplyCount];
        //        }
    }
}

// 已经同意并且加入群组后的回调
- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error
{
    if(error)
    {
        return;
    }
    
    NSString *groupTag = group.groupSubject;
    if ([groupTag length] == 0) {
        groupTag = group.groupId;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed and joined the group of \'%@\'"), groupTag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}


// 绑定deviceToken回调
- (void)didBindDeviceWithError:(EMError *)error
{
    if (error) {
        //        TTAlertNoTitle(NSLocalizedString(@"apns.failToBindDeviceToken", @"Fail to bind device token"));
    }
}

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    //    [self.mainController networkChanged:connectionState];
}

// 打印收到的apns信息
-(void)didReiveceRemoteNotification:(NSDictionary *)userInfo{
//    NSError *parseError = nil;
//    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
//                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
//    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送内容"
//                                                    message:str
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                          otherButtonTitles:nil];
//    [alert show];
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
@end


