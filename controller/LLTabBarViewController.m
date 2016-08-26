//
//  LLTabBarViewController.m
//  Olla
//
//  Created by nonstriater on 14-7-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLTabBarViewController.h"
#import "LLTabbarBadgeController.h"
#import "LLImageBrowserController.h"


@interface LLTabBarViewController ()<UITabBarControllerDelegate,UITabBarDelegate>

@end

@implementation LLTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    if(IS_IOS7)
    {
//        self.tabBar.barStyle = UIBarStyleBlackTranslucent;
        self.tabBar.translucent = NO;
        [self.tabBar setBarTintColor:RGBA_HEX(0xf9f9f9,0.9)];
        [self.tabBar setTintColor:RGB_HEX(0xe21001)];
    }
//    else
//    {
//       
//        [self.tabBar setBackgroundColor:RGBA_HEX(0x221F1F,0.95)];
//       [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB_HEX(0xe21001),UITextAttributeTextColor, nil] forState:UIControlStateSelected];
//   }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupBadgeSerive];
}


- (void)setupBadgeSerive{

    //tabbarcontrollers
    [[LLTabbarBadgeController shareController] setTabbarController:self];
 
    // 随应用启动的服务
    [[LLImageBrowserController sharedInstance] setViewController:self];
}

- (void)dealloc{
    DDLogError(@"********登出时，这个必须要释放！！***************..%@",self);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
