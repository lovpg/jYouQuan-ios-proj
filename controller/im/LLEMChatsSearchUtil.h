//
//  LLEMChatsSearchUtil.h
//  Olla
//
//  Created by Pat on 15/3/31.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

typedef void (^LLEMChatSearchResultBlock)(NSArray *results);

@interface LLEMChatsSearchUtil : NSObject

AS_SINGLETON(LLEMChatsSearchUtil, sharedUtil);

- (void)searchText:(NSString *)text dataSource:(NSArray *)dataSource resultBlock:(LLEMChatSearchResultBlock)resultBlock;

@end
