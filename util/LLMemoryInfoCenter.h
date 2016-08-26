//
//  HTMemoryInfoCenter.h
//
//  Created by Pat Ren on 12-10-15.
//  Copyright (c) 2012年 Weiwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface LLMemoryInfoCenter : NSObject
@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) UILabel *label;


AS_SINGLETON(LLMemoryInfoCenter, defaultCenter)
- (void)showMemoryUsage;
- (void)hideMemoryUsage;
- (BOOL)isVisible;

@end
