//
//  LLTabbarBadgeController.m
//  Olla
//
//  Created by nonstriater on 14-8-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLTabbarBadgeController.h"

@implementation LLTabbarBadgeController

+ (id)shareController{
    static LLTabbarBadgeController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LLTabbarBadgeController alloc] init];
    });
    
    return instance;
}

- (void)setTabbarController:(UITabBarController *)tabbarController
{
    if (_tabbarController != tabbarController) {
        _tabbarController = tabbarController;
        
        for (int i=0; i<[tabbarController.viewControllers count]; i++) {
            int value = [[[LLPreference shareInstance] valueForKey:[LLAppHelper tabBadgeKeyAtIndex:i]] intValue];
            [[LLTabbarBadgeController shareController] setTabbarBadgeWithValue:value atIndex:i];//未读消息
        }
    }
}


- (void)clearAll
{

    for (UIViewController *vc in [self.tabbarController viewControllers])
    {
        [vc.tabBarItem setBadgeValue:nil];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


// TODO 这个是可以复用的
- (void)setTabbarBadgeWithValue:(int)value atIndex:(NSInteger)index{

    if (index>=[[self.tabbarController viewControllers] count] || index<0) {
        return ;
    }
    
    UIViewController *vc  =[self.tabbarController viewControllers][index];
    if (value==0)
    {
        [vc.tabBarItem setBadgeValue:nil];
    }else{
        [vc.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",value]];
    }
    
    [[LLPreference shareInstance] setValue:@(value) forKey:[LLAppHelper tabBadgeKeyAtIndex:index]];
    
    [self setIconBadgeValue];
    
}//设置一个值

- (void)increaseTabbarBadgeValueAtIndex:(NSInteger)index{

    if (index>=[[self.tabbarController viewControllers] count]) {
        return ;
    }
    
    UIViewController *vc  =[self.tabbarController viewControllers][index];
    int value = [vc.tabBarItem.badgeValue intValue];
    [vc.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",value+1]];
    
    [[LLPreference shareInstance] setValue:@(value+1) forKey:[LLAppHelper tabBadgeKeyAtIndex:index]];

    [self setIconBadgeValue];
}

- (void)decreaseTabbarBadgeValueBy:(int)decreaseValue atIndex:(NSInteger)index{
    
    if (index>=[[self.tabbarController viewControllers] count]) {
        return ;
    }
    
    UIViewController *vc  =[self.tabbarController viewControllers][index];
    int value = [vc.tabBarItem.badgeValue intValue];
    int last = value - decreaseValue;
    if (last<0) {
        last = 0;
    }
    if (last==0) {
       [vc.tabBarItem setBadgeValue:nil];
    }else{
        [vc.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",last]];
    }
    
    
    [[LLPreference shareInstance] setValue:@(last) forKey:[LLAppHelper tabBadgeKeyAtIndex:index]];

    [self setIconBadgeValue];
    
}


// 设置icon badge 数量，将tabbar上的各个badge相加
- (void)setIconBadgeValue{

    NSInteger total = 0;
    NSArray *vcs  =[self.tabbarController viewControllers];
    for (UIViewController *vc in vcs) {
        total += [vc.tabBarItem.badgeValue intValue];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:total];
}


@end


