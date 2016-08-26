//
//  LLBaseViewController.h
//  Olla
//
//  Created by nonstriater on 14-7-25.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//
#import "LLCoreViewController.h"

//适配（iOS6，7）
@interface LLBaseViewController : LLCoreViewController

@property (nonatomic,weak) IBOutlet UIView *headView;
@property (nonatomic,weak) IBOutlet UIButton *leftBarButton;
@property (nonatomic,weak) IBOutlet UIButton *rightBarButton;
@property (nonatomic,weak) IBOutlet UIView *titleView;
@property (nonatomic,weak) IBOutlet UIView *contentView;



@property (nonatomic,assign) BOOL needHeadBackgroundImage;


//通知不到的情况
- (void)forceLoadView;


@end
