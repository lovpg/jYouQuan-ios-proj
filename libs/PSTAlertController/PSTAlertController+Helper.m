//
//  PSTAlertController+Helper.m
//  ShortURLMaker
//
//  Created by Pat on 15/1/19.
//  Copyright (c) 2015年 Pat. All rights reserved.
//

#import "PSTAlertController+Helper.h"

@implementation PSTAlertController (Helper)

+ (void)showMessage:(NSString *)message {
    [self showTitle:nil message:message];
}

+ (void)showTitle:(NSString *)title message:(NSString *)message {
    PSTAlertController *alertVC = [PSTAlertController alertWithTitle:title message:message];
    [alertVC addAction:[PSTAlertAction actionWithTitle:@"OK" handler:NULL]];
    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [alertVC showWithSender:nil controller:vc animated:YES completion:NULL];
}

+ (void)showBossMessage:(NSString *)message {
    if (!Olla_Show_BossMessage) {
        return;
    }
    PSTAlertController *alertVC = [PSTAlertController alertWithTitle:@"测试版专用提示" message:message];
    [alertVC addAction:[PSTAlertAction actionWithTitle:@"OK" handler:NULL]];
    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [alertVC showWithSender:nil controller:vc animated:YES completion:NULL];
}

@end
