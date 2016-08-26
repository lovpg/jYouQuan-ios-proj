//
//  LLSendMessageQeueu.h
//  Olla
//
//  Created by null on 14-9-4.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLSendMessageItem.h"
#import "LLIMClientProtocol.h"
//
@interface LLSendMessageQueue : NSObject{
    
    
    
}

//这里设置一个代理以后，怎么测试？
@property(nonatomic,assign) id<LLIMClientProtocol> delegate;

- (void)start;
- (void)stop;

- (NSInteger)count;

- (void)onRead:(NSString *)cmd status:(NSString *)status message:(NSDictionary *)message;

- (void)addMessage:(LLSendMessageItem *)message;

@end
