//
//  LLQuickTutorService.m
//  Olla
//
//  Created by Pat on 15/10/19.
//  Copyright © 2015年 xiaoran. All rights reserved.
//

#import "LLQuickTutorService.h"
#import "LLQuickTutor.h"

@interface LLQuickTutorService () {
}

@property (nonatomic, strong) NSArray *items;

@end

@implementation LLQuickTutorService

DEF_SINGLETON(LLQuickTutorService, sharedService);

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

// 同步服务端数据
- (void)synchronize {
    [self synchronizeWithCompletion:nil];
}


- (void)synchronizeWithCompletion:(dispatch_block_t)block {
    [[LLHTTPRequestOperationManager shareManager] GETListWithURL:Olla_API_Quick_Tutor_Processing_List parameters:nil modelType:[LLQuickTutor class] success:^(NSArray *items, BOOL hasNext) {
        self.items = items;
        
        if (block) {
            block();
        }
    } failure:^(NSError *error) {
        if (block) {
            block();
        }
    }];
}

// 判断是否在进行付费聊天
- (LLQuickTutor *)quickTutorWithUid:(NSString *)uid {
    
    for (LLQuickTutor *item in self.items) {
        if ([item.uid isEqualToString:uid] || [item.ouid isEqualToString:uid]) {
            return item;
        }
    }
    
    return nil;
}

- (LLQuickTutor *)quickTutorWithChatId:(NSString *)chatId {
    
    for (LLQuickTutor *item in self.items) {
        if ([item.chatId isEqualToString:chatId]) {
            return item;
        }
    }
    
    return nil;
}


- (void)getQuickTutorWithChatId:(NSString *)chatId completionBlock:(void (^)(LLQuickTutor *quickTutor))block {
    if (chatId.length == 0) {
        if (block) {
            block(nil);
        }
    }
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Quick_Tutor_Status parameters:@{@"chatId":chatId} modelType:[LLQuickTutor class] success:^(OllaModel *model) {
        if (model) {
            if (block) {
                block((LLQuickTutor *)model);
            }
        }
    } failure:^(NSError *error) {
        if (block) {
            block(nil);
        }
    }];
}

@end
