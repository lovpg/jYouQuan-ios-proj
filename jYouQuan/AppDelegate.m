//
//  AppDelegate.m
//  leshi
//
//  Created by Reco on 16/6/30.
//  Copyright © 2016年 广州市乐施信息科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "LLTabbarBadgeController.h"




#define ScreenHeight [[UIScreen mainScreen] bounds].size.height//获取屏幕高度，兼容性测试
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width//获取屏幕宽度，兼容性测试

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSThread sleepForTimeInterval:2];


    [super application:application didFinishLaunchingWithOptions:launchOptions];
    if (![loginService checkLogined])
    {
        self.window.rootViewController = [self rootViewControllerWithURLKey:@"login"];
    }
    else
    {  // 不是第一次启动, 登录
        
        self.userAuth = [[loginService loginAuthDAO] get];
        [LLFMDB setIdentifier:self.userAuth.uid];
        [LLAPICache setIdentifier:self.userAuth.uid];
        [[LLPreference shareInstance] setUid:self.userAuth.uid];
        [[LLHTTPRequestOperationManager shareManager] setUserAuth:self.userAuth];
        [[LLHTTPWriteOperationManager shareWriteManager] setUserAuth:self.userAuth];
        
        //这一句要在OllaPreference设置uid的下面，offlinemessageService要在VC的-init判断消息数量
        self.window.rootViewController = [self rootViewControllerWithURLKey:@"lbslm"];
        
    }
    //启用启动是创建一次
    if (!_messageManager)
    {
        LLLoginAuth *auth = [[loginService loginAuthDAO] get];
        _messageManager = [[LLIMContext alloc] initWithUid:auth.uid token:auth.token];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    if(IS_IOS7)
    {
        [[UINavigationBar appearance] setBarTintColor:RGB_HEX(0xe21001)];
    }
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    return YES;
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
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)logout
{
    [loginService logout];
    [LLFMDB close];
    [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:nil];
    [[LLTabbarBadgeController shareController] clearAll];
    //退出登录断开
    [self messageManagerStop];
    [LLAppHelper clearCookies];
    [[[UIApplication sharedApplication] delegate] window].rootViewController = [self rootViewControllerWithURLKey:@"login"];
}

- (void)messageManagerStart{
    
    if (_messageManager){
        [self messageManagerStop];
    }
    
    LLLoginAuth *auth = [[loginService loginAuthDAO] get];
    _messageManager.uid = auth.uid;
    _messageManager.token = auth.token;
    [_messageManager start];
    
}

//退出登录时使用
- (void)messageManagerStop{
    
    if (_messageManager)
    {
        [_messageManager stop];
    }
}

//storyBoard view自动适配
+ (void)storyBoradAutoLay:(UIView *)allView
{
    //    allView.frame = CGRectMake1(allView.frame.origin.x, allView.frame.origin.y, allView.frame.size.width, allView.frame.size.height);
    for (UIView *temp in allView.subviews) {
        temp.frame = CGRectMake1(temp.frame.origin.x, temp.frame.origin.y, temp.frame.size.width, temp.frame.size.height);
        for (UIView *temp1 in temp.subviews) {
            temp1.frame = CGRectMake1(temp1.frame.origin.x, temp1.frame.origin.y, temp1.frame.size.width, temp1.frame.size.height);
        }
    }
}
+ (CGRect)getFrame : (CGRect) orign
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = orign.origin.x * myDelegate.autoSizeScaleX;
    rect.origin.y = orign.origin.y * myDelegate.autoSizeScaleY;
    rect.size.width = orign.size.width * myDelegate.autoSizeScaleX;
    rect.size.height = orign.size.height * myDelegate.autoSizeScaleY;
    return rect;
}
//修改CGRectMake
CG_INLINE CGRect
CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX;
    rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX;
    rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cooci.iDleChat" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iDleChat" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iDleChat.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
-(BOOL)application:(UIApplication*)application
           openURL:(NSURL*)url
 sourceApplication:(NSString*)sourceApplication
        annotation:(id)annotation
{
    NSLog(@"%@",url);
    return TRUE;
}

-(BOOL)application:(UIApplication*)app
           openURL:(NSURL*)url
           options:(NSDictionary<NSString*,id>*)options

{
    NSLog(@"%@",url);
    return TRUE;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // Do something with the url here
    NSLog(@"%@",url);
    return TRUE;
}




@end
