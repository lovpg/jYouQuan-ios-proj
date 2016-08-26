//
//  LLQuickTutor.h
//  Olla
//
//  Created by Pat on 15/10/14.
//  Copyright © 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    LLQuickTutorStatusSetup = 0,
    LLQuickTutorStatusStart = 1,
    LLQuickTutorStatusFinish = 2,
    LLQuickTutorStatusRollback = 3,
    LLQuickTutorStatusReject = 4,
    LLQuickTutorStatusCancel = 9
} LLQuickTutorStatus;

typedef enum : NSUInteger {
    LLQuickTutorActionTypeAsk,
    LLQuickTutorActionTypeCancel,
    LLQuickTutorActionTypeAccept,
    LLQuickTutorActionTypeReject,
    LLQuickTutorActionTypeFinish,
    LLQuickTutorActionTypeTips   // 加赏
} LLQuickTutorActionType;

@interface LLQuickTutor : OllaModel <NSCopying>

@property (nonatomic, strong) NSString *uid;  // 学方
@property (nonatomic, strong) NSString *ouid; // 教方
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *coin;
@property (nonatomic, strong) NSString *lang;
@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) double posttime;

@end
