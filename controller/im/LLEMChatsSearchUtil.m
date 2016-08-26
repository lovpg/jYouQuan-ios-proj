//
//  LLEMChatsSearchUtil.m
//  Olla
//
//  Created by Pat on 15/3/31.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLEMChatsSearchUtil.h"
#import "LLEMChatsItem.h"
#import "EMConversation+Helper.h"
//#import "GCDObjC.h"

@interface LLEMChatsSearchUtil () {
    NSOperationQueue *searchQueue;
}

@end

@implementation LLEMChatsSearchUtil

DEF_SINGLETON(LLEMChatsSearchUtil, sharedUtil);

-(instancetype)init {
    self = [super init];
    if (self) {
        searchQueue = [[NSOperationQueue alloc] init];
        searchQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)searchText:(NSString *)text dataSource:(NSArray *)dataSource resultBlock:(LLEMChatSearchResultBlock)resultBlock {
    [searchQueue cancelAllOperations];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray *results = [NSMutableArray array];
        for (LLEMChatsItem *chatsItem in dataSource) {
            LLUser *userInfo = chatsItem.userInfo;
            EMConversation *conversation = chatsItem.conversation;
            if ([userInfo.nickname.lowercaseString containsSubString:text.escapeSpace.lowercaseString] ||
                [conversation.messageContent.lowercaseString containsSubString:text.escapeSpace.lowercaseString]) {
                [results addObject:chatsItem];
            }
        }
//        
//        [[GCDQueue mainQueue] queueBlock:^{
//            resultBlock(results);
//        }];
    }];
    
    [searchQueue addOperation:operation];
    
}



@end
