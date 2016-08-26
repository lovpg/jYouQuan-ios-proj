//
//  LLIMClientProtocol.h
//  Olla
//
//  Created by null on 14-9-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLSendMessageItem.h"
#import "LLIMReceiveProtocol.h"

@protocol LLIMClientProtocol <NSObject>

- (void)start;
- (void)stop;
- (void)stop:(long)waitTime;

// 发送到消息队列
- (void)send:(LLSendMessageItem *)message;
// 直接发一条消息（如ack，lucky 用）
- (void)writeln:(NSString *)message;



- (void)onConnect;
- (void)onDisconnect;

- (BOOL)isActive;

- (void)setOnReceiveListener:(id<LLIMReceiveProtocol>)onReceiveListener;


//void setLoginInfo(long uid, String password);

@end



