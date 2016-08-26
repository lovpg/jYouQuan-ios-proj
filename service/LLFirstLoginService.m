//
//  LLFirstLoginService.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLFirstLoginService.h"

@implementation LLFirstLoginService

- (instancetype)init{
    if (self= [super init]) {
        firstLoginDAO = [[LLFirstLoginDAO alloc] init];
    }
    return self;
}

- (void)setFirstLogin:(BOOL)firstLogin{
    
    [firstLoginDAO setFirstLogin:firstLogin];
}

- (BOOL)isFirstLogin{
    return [firstLoginDAO isFirstLogin];
}

- (void)clear{
    
    [firstLoginDAO clear];
}

@end
