//
//  HTMemoryInfoCenter.m
//  Meeapp
//
//  Created by Pat Ren on 12-10-15.
//  Copyright (c) 2012年 Weiwo. All rights reserved.
//

#import "LLMemoryInfoCenter.h"
#import "UIDevice+Hardware.h"

@interface  LLMemoryInfoCenter (Private)
- (void)updateMemoryUsage;
@end


@implementation LLMemoryInfoCenter

DEF_SINGLETON(LLMemoryInfoCenter, defaultCenter);

- (id)init {
    self = [super init];
    if (self) {
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
        _window.windowLevel = UIWindowLevelStatusBar + 10;
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 19.0f)];
        _label.textColor = RGB_DECIMAL(191, 191, 191);
        _label.backgroundColor = [UIColor blackColor];
        _label.font = [UIFont boldSystemFontOfSize:13.5f];
        _label.textAlignment = NSTextAlignmentCenter;
        
        [_window addSubview:_label];
    }
    return self;
}

- (BOOL)isVisible {
    return !self.window.hidden;
}

- (void)showMemoryUsage {
    self.window.hidden = NO;
    [self updateMemoryUsage];
}

- (void)hideMemoryUsage {
    self.window.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)updateMemoryUsage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cpuUsage = [[UIDevice currentDevice] cpuUsage];
        NSString *memoryUsage = [[UIDevice currentDevice] memoryUsage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = [NSString stringWithFormat:@"CPU:%@ MEM:%@", cpuUsage, memoryUsage];
        });

    });
    [self performSelector:@selector(updateMemoryUsage) withObject:nil afterDelay:0.4];
}

@end
