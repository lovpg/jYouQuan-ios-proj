//
//  KZVideoViewController.h
//  KZWeChatSmallVideo_OC
//
//  Created by Corporal on 16/7/18.
//  Copyright © 2016年 Corporal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KZVideoConfig.h"
@protocol KZVideoViewControllerDelegate;

// 主类  更多自定义..修改KZVideoConfig.h里面的define
@interface KZVideoViewController : LLBaseViewController

//@property (nonatomic, strong, readonly) UIView *view;

@property (nonatomic, strong, readonly) UIView *actionView;

//保存到相册
@property (nonatomic, assign) BOOL savePhotoAlbum;

@property (nonatomic, weak) id<KZVideoViewControllerDelegate> delegate;

@property (nonatomic, assign) KZVideoViewShowType Typeshowing;

- (void)startAnimationWithType:(KZVideoViewShowType)showType;

//- (void)endAniamtion;

@end

@protocol KZVideoViewControllerDelegate <NSObject>


@optional
- (void)videoViewControllerDidCancel:(KZVideoViewController *)videoController;

@end