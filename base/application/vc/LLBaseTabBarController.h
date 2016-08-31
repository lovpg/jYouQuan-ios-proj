//
//  OllaTabBarController.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBaseUIViewController.h"
#import "EMChatManagerDelegate.h"


@interface LLBaseTabBarController : UITabBarController<IBaseUIViewController,EMChatManagerDelegate>
{
    UIImageView *_groupBarTabView;
}

- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;



@end
