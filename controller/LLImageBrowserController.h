//
//  LLImageBrowserController.h
//  Olla
//
//  Created by nonstriater on 14-8-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//


// 应用启动时就工作，专门用来处理大图浏览的
@interface LLImageBrowserController : OllaController

@property(nonatomic,strong) UIViewController *viewController;

+ (id)sharedInstance;

/**
 *  用来预览share上的图片，这里只需要提供thubmImages,orignal images url根据thumb就可计算
 *  @param images
 *  @param index
 */
- (void)thumbsImages:(NSArray *)images selectAtIndex:(NSInteger)index;

@end
