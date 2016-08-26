//
//  LLQuickTutor.m
//  Olla
//
//  Created by Pat on 15/10/14.
//  Copyright © 2015年 xiaoran. All rights reserved.
//

#import "LLQuickTutor.h"

@implementation LLQuickTutor

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = -1;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    
    LLQuickTutor *quickTutor = [[[self class] allocWithZone:zone] init];
    quickTutor.uid = self.uid;
    quickTutor.ouid = self.ouid;
    quickTutor.chatId = self.chatId;
    quickTutor.lang = self.lang;
    quickTutor.action = self.action;
    quickTutor.coin = self.coin;
    quickTutor.status = self.status;
    quickTutor.points = self.points;
    quickTutor.posttime = self.posttime;
    return quickTutor;
}

@end
