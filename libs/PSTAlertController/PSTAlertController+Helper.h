//
//  PSTAlertController+Helper.h
//  ShortURLMaker
//
//  Created by Pat on 15/1/19.
//  Copyright (c) 2015年 Pat. All rights reserved.
//

#import "PSTAlertController.h"

@interface PSTAlertController (Helper)

+ (void)showMessage:(NSString *)message;
+ (void)showTitle:(NSString *)title message:(NSString *)message;


// 老鹰专用提示
+ (void)showBossMessage:(NSString *)message;

@end
