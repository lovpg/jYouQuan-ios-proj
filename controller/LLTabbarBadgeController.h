//
//  LLTabbarBadgeController.h
//  Olla
//
//  Created by nonstriater on 14-8-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//


@interface LLTabbarBadgeController : OllaController

// 依赖tabbarController,这里不要强引用
@property(nonatomic,weak) UITabBarController *tabbarController;

+ (id)shareController;

// TODO 这个是可以复用的
- (void)setTabbarBadgeWithValue:(int)value atIndex:(NSInteger)index;//设置一个值
- (void)increaseTabbarBadgeValueAtIndex:(NSInteger)index;//在原有基础商加一个数
- (void)decreaseTabbarBadgeValueBy:(int)decreaseValue atIndex:(NSInteger)index;//减少n个数

- (void)clearAll;

@end
