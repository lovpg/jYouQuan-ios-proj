//
//  LLMessageService.h
//  Olla
//
//  Created by null on 14-12-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLMessage.h"

@interface LLMessageService : NSObject

- (NSArray *)list;
- (BOOL)addMessage:(LLMessage *)message;
- (BOOL)deleteMessage:(LLMessage *)message;

@end
