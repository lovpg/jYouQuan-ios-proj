//
//  LLSupplyProfileService.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLSupplyProfileService.h"

@implementation LLSupplyProfileService

DEF_SINGLETON(LLSupplyProfileService, sharedService);

- (instancetype)init{
    if (self=[super init]) {
        meDAO = [[LLMeDAO alloc] init];
    }
    return self;
}

- (BOOL)needSupply{
    
    return [self anyUserInfoEmpty];
}

//是否有一项为空
- (BOOL)anyUserInfoEmpty{
    
    LLUser *user = [meDAO get];
    
    if ([user.learning length]==0 ||
        [user.learning length]==0 ||
//        [user.gender length]==0 ||
        [user.region length]==0 ||
        [user.nickname length]==0) {
        
        return YES;
    }
    
    return NO;
}


@end
