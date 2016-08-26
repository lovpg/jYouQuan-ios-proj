//
//  MBProgressHUD+addtions.m
//  OllaFramework
//
//  Created by nonstriater on 14-8-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "MBProgressHUD+addtions.h"

@implementation MBProgressHUD (addtions)

+ (void)showWithTitle:(NSString *)title inView:(UIView *)view{
    [MBProgressHUD showWithTitle:title inView:view disappearedAfter:1.2];
}
+ (void)showWithTitle:(NSString *)title inView:(UIView *)view disappearedAfter:(CFTimeInterval)interval{
    
    [MBProgressHUD showWithTitle:title inView:view disappearedAfter:interval finishBlock:nil];
}

+ (void)showWithTitle:(NSString *)title inView:(UIView *)view disappearedAfter:(CFTimeInterval)interval finishBlock:(void (^)())block{

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    [hud setLabelText:title];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(interval);
    } completionBlock:^{
        [hud removeFromSuperview];
        if (block) {
            block();
        }

    }];
}

+ (void)showWithTitle:(NSString *)title inView:(UIView *)view whileExecuteBlock:(void (^)())execute finishBlock:(void (^)())block{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    [hud setLabelText:title];
    [hud showAnimated:YES whileExecutingBlock:^{
        if(execute){
            execute();
        }
       
    } completionBlock:^{
        [hud removeFromSuperview];
        if (block) {
            block();
        }
        
    }];
    
    
}

+ (void)showWithTitle:(NSString *)title customImage:(UIImage *)image inView:(UIView *)view {
    [MBProgressHUD showWithTitle:title customImage:image inView:view disappearedAfter:1.2];
}

+ (void)showWithTitle:(NSString *)title customImage:(UIImage *)image inView:(UIView *)view disappearedAfter:(CFTimeInterval)interval{


}


@end
