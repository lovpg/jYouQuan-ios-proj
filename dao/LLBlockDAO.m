//
//  LLBlockDAO.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBlockDAO.h"

@implementation LLBlockDAO

- (void)setBlocked:(BOOL)blocked{
    NSString *b = blocked?@"blocking":@"follow my rules,or you will be blocking";
    [OllaKeychain setPassword:b forService:@"com.between.olla" account:@"block" error:nil];

}

-(BOOL)isBlocked{
    NSString *block = [OllaKeychain passwordForService:@"com.between.olla" account:@"block" error:nil];
    if ([block isEqualToString:@"blocking"]) {
        return YES;
    }
    
    return NO;
}

@end
