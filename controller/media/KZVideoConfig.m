//
//  KZVideoConfig.m
//  KZWeChatSmallVideo_OC
//
//  Created by Corporal on 16/7/19.
//  Copyright © 2016年 Corporal. All rights reserved.
//

#import "KZVideoConfig.h"
#import <AVFoundation/AVFoundation.h>


void kz_dispatch_after(float time, dispatch_block_t block)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

@implementation KZVideoConfig

+ (CGRect)viewFrameWithType:(KZVideoViewShowType)type {
    if (type == KZVideoViewShowTypeSingle) {
        return [UIScreen mainScreen].bounds;
    }
    CGFloat viewHeight = kzSCREEN_WIDTH/kzVideo_w_h + 20 + kzControViewHeight;
    return CGRectMake(0, kzSCREEN_HEIGHT - viewHeight, kzSCREEN_WIDTH, viewHeight);
}

+ (CGSize)videoViewDefaultSize {
    return CGSizeMake(kzSCREEN_WIDTH, kzSCREEN_WIDTH/kzVideo_w_h);
}

+ (CGSize)defualtVideoSize {
    return CGSizeMake(kzVideoWidthPX, kzVideoWidthPX/kzVideo_w_h);
}

+ (NSArray *)gradualColors {
    return @[(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor yellowColor].CGColor,];
}

+ (void)motionBlurView:(UIView *)superView
{
    superView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:superView.bounds];
    [bar setBarStyle:UIBarStyleBlackTranslucent];
    bar.clipsToBounds = YES;
    [superView addSubview:bar];
}

+ (void)showHinInfo:(NSString *)text inView:(UIView *)superView frame:(CGRect)frame timeLong:(NSTimeInterval)time {
    __block UILabel *zoomLab = [[UILabel alloc] initWithFrame:frame];
    zoomLab.font = [UIFont boldSystemFontOfSize:15.0];
    zoomLab.text = text;
    zoomLab.textColor = [UIColor whiteColor];
    zoomLab.textAlignment = NSTextAlignmentCenter;
    [superView addSubview:zoomLab];
    [superView bringSubviewToFront:zoomLab];
    kz_dispatch_after(1.6, ^{
        [zoomLab removeFromSuperview];
    });
}

@end








