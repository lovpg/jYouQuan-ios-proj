//
//  LLQuickTutorService.h
//  Olla
//
//  Created by Pat on 15/10/19.
//  Copyright © 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "LLQuickTutor.h"

@interface LLQuickTutorService : NSObject

AS_SINGLETON(LLQuickTutorService, sharedService);

// 同步服务端数据
- (void)synchronize;
- (void)synchronizeWithCompletion:(dispatch_block_t)block;
// 判断是否在进行付费聊天
- (LLQuickTutor *)quickTutorWithUid:(NSString *)uid;
- (LLQuickTutor *)quickTutorWithChatId:(NSString *)chatId;

- (void)getQuickTutorWithChatId:(NSString *)chatId completionBlock:(void (^)(LLQuickTutor *quickTutor))block;

@end
