//
//  LLBLockService.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBLockService.h"

@implementation LLBLockService

- (instancetype)init{
    if(self=[super init]){
        blockDAO = [[LLBlockDAO alloc] init];
    }
    return self;
}

- (void)setBlocked:(BOOL)blocked{
    [blockDAO setBlocked:blocked];
}

-(BOOL)isBlocked{
    return [blockDAO isBlocked];
}

@end
