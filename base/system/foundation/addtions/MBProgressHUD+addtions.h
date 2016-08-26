//
//  MBProgressHUD+addtions.h
//  OllaFramework
//
//  Created by nonstriater on 14-8-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

@interface MBProgressHUD (addtions)

+ (void)showWithTitle:(NSString *)title inView:(UIView *)view;
+ (void)showWithTitle:(NSString *)title inView:(UIView *)view disappearedAfter:(CFTimeInterval)interval;
+ (void)showWithTitle:(NSString *)title inView:(UIView *)view disappearedAfter:(CFTimeInterval)interval finishBlock:(void (^)())block;
+ (void)showWithTitle:(NSString *)title inView:(UIView *)view whileExecuteBlock:(void (^)())execute finishBlock:(void (^)())block;

+ (void)showWithTitle:(NSString *)title customImage:(UIImage *)image inView:(UIView *)view ;
+ (void)showWithTitle:(NSString *)title customImage:(UIImage *)image inView:(UIView *)view disappearedAfter:(CFTimeInterval)interval;

@end
