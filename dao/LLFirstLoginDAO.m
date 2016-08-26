//
//  LLFirstLoginDAO.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLFirstLoginDAO.h"

@implementation LLFirstLoginDAO

- (void)setFirstLogin:(BOOL)firstLogin{

    [[LLPreference shareInstance] setValue:@(firstLogin) forKey:@"firstLogin"];
}

- (BOOL)isFirstLogin{
  
    return [[[LLPreference shareInstance] valueForKey:@"firstLogin"] boolValue];
}

- (void)clear{

    [[LLPreference shareInstance] removeValueForKey:@"firstLogin"];
}


@end
