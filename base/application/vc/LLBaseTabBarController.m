//
//  OllaTabBarController.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBaseTabBarController.h"
#import "JSONAdapter.h"
#import "AppDelegate.h"
#import "RKNotificationHub.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface LLBaseTabBarController () <UITabBarControllerDelegate>
{
    UIImageView *_groupBarTabView;
}

@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property (nonatomic, strong) RKNotificationHub *groupBarHub;

@property (nonatomic) BOOL isEmailBinded;
@property (nonatomic) BOOL isBirthBinded;
@property (nonatomic) BOOL *isHomelandBinded;
@property (nonatomic) BOOL *isNativeBinded;
@property (nonatomic) BOOL *isLearningbinded;



@property (nonatomic) BOOL isNewUser;

@property (nonatomic) int emailC;

@end

@implementation LLBaseTabBarController

@synthesize context = _context;
@synthesize config = _config;
@synthesize url = _url;
@synthesize params = _params;
@synthesize alias = _alias;
@synthesize scheme = _scheme;
@synthesize controllers = _controller;
@synthesize parentController = _parentController;

@synthesize styleContainer = _styleContainer;


- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isEmailBinded = YES;
        _isBirthBinded = YES;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNotifications];
    
//    // 更换图标
//    _groupBarTabView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_group_bar_normal_new"] highlightedImage:[UIImage imageNamed:@"tab_group_bar_selected_new"]];
//    _groupBarTabView.frame = CGRectMake(0, 0, 50, 50);
//    _groupBarTabView.center = CGPointMake(self.tabBar.width / 2, self.tabBar.height / 2);
//    _groupBarTabView.userInteractionEnabled = YES;
//    [self.tabBar insertSubview:_groupBarTabView atIndex:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callOutWithChatter:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callControllerClose:) name:@"callControllerClose" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUnreadCount:) name:@"reloadUnreadCount" object:nil];
    
    
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBadgeForBindEmail" object:@{@"isBindEmail":@(isRedPoint)}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount:) name:@"updateBadgeForBindEmail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount:) name:@"updateBadgeForBindBirth" object:nil];
    //红色星号
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount:) name:@"updateBadgeBindHomeland" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount:) name:@"updateBadgeBindNative" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount:) name:@"updateBadgeBindLearning" object:nil];
    
    
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserAndShowBadgeInCommentTabBar" object:@{@"isNewUser":@(YES)}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCountForNewUser:) name:@"newUserAndShowBadgeInCommentTabBar" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalCount:) name:@"isEmailBindNotification" object:nil];
    
    self.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self setupUnreadMessageCount];
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 2) {
        _groupBarTabView.highlighted = YES;
    } else {
        _groupBarTabView.highlighted = NO;
    }
}


#pragma mark - private

-(void)registerNotifications
{
    [self unregisterNotifications];
    
}

-(void)unregisterNotifications
{

}

-(void)reloadUnreadCount:(NSNotification *)notification
{
}

- (void)updateUnreadCount:(NSNotification *)notification {

    // [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBadgeForBindEmail" object:@{@"isBindEmail":@(isRedPoint)}];
    self.isEmailBinded = [[notification.userInfo objectForKey:@"isBindEmail"] boolValue];
    self.isBirthBinded = [[notification.userInfo objectForKey:@"isBindBirth"] boolValue];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserAndShowBadgeInCommentTabBar" object:@{@"isNewUser":@(YES)}];
//    self.isNewUser = [notification.userInfo objectForKey:@""]
}

- (void)updateTotalCount:(NSNotification *)notification
{

    if ([[notification.userInfo valueForKey:@"updateTotalCount"] boolValue])
    {
    }
}

// [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserAndShowBadgeInCommentTabBar" object:@{@"isNewUser":@(YES)}];

- (void)updateUnreadCountForNewUser:(NSNotification *)notification
{

    self.isNewUser = [[notification.userInfo objectForKey:@"isNewUser"] boolValue];

}




#pragma mark - IChatManagerDelegate 消息变化

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
}

- (void)didFinishedReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    
}

- (BOOL)needShowNotification:(NSString *)fromChatter
{
    return true;
}




#pragma mark - public

- (void)jumpToChatList
{

}

- (void)setConfig:(id)config{
    if (_config != config) {
        _config = config;
        
        NSArray *items = [config valueForKey:@"items"];
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:4];
        for (id item in items) {
            if (![item isKindOfClass:[NSDictionary class]]) {
                return ;
            }
            
            id controller = [self.context getViewController:[NSURL URLWithString:item[@"url"]] basePath:@"/"];
            if (controller && [controller isKindOfClass:[UIViewController class]]) {
                if (item[@"title"]) {
                    [[controller tabBarItem] setTitle:item[@"title"]];
                }
                if (item[@"image"]) {
                    UIImage *normalImage = [UIImage imageNamed:item[@"image"]];
                    if (IS_IOS7) {
                        normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }
                    [[controller tabBarItem] setImage:normalImage];
                    
                    NSString *selectImageName = item[@"selectedImage"];
                    if (!selectImageName) {
                        selectImageName = [item[@"image"] stringByAppendingString:@"_h"];
                    }
                    if (selectImageName) {
                        
                        if (IS_IOS7) {
                            UIImage *selectImage = [[UIImage imageNamed:selectImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                            UITabBarItem *barItem = [[UITabBarItem alloc] initWithTitle:item[@"title"] image:[UIImage imageNamed:item[@"image"]] selectedImage:selectImage];
                            
                            [controller setTabBarItem:barItem];
                        }else{
                            
                            [[controller tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:selectImageName] withFinishedUnselectedImage:normalImage];
                        }
                    }
                }
                
                [controller setParentController:self];
                [controller loadURL:[NSURL URLWithString:item[@"url"]] basePath:@"/" animated:NO];
                [viewControllers addObject:controller];
            }
            
        }
        
        [self setViewControllers:viewControllers];
        
        UINavigationController *nav = [viewControllers objectAtIndex:1];
    }

}

-(BOOL)canOpenURL:(NSURL *)url{
    return NO;
}


- (BOOL)openURL:(NSURL *)url animated:(BOOL)animation{
    return [self openURL:url params:nil animated:animation];
}

- (BOOL)openURL:(NSURL *)url params:(id)params animated:(BOOL)animation{

    return [_parentController openURL:url params:params animated:animation];
}


- (NSString *)loadURL:(NSURL *)url basePath:(NSString *)basePath animated:(BOOL)animation{
    
    return [basePath stringByAppendingPathComponent:self.alias];
}

- (NSString *)loadURL:(NSURL *)url basePath:(NSString *)basePath params:(id)params animated:(BOOL)animation{

    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
