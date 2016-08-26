//
//  OllaImageBrowserController.h
//  OllaFramework
//
//  Created by nonstriater on 14-8-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

//封装MWPhotoBrowser
@interface OllaImageBrowserController : UINavigationController

@property(nonatomic,strong) NSArray *images;
@property(nonatomic,strong) NSArray *thumbImages;
@property(nonatomic,assign) NSUInteger currentIndex;


// 当重新给数据时images，要刷新
- (void)reloadData;

@end
