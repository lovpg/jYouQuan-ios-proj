//
//  OllaTabBarController.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBaseUIViewController.h"


@interface LLBaseTabBarController : UITabBarController<IBaseUIViewController>
{

}

- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;



@end
