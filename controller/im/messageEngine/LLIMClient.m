//
//  LLIMClient.m
//  Olla
//
//  Created by null on 14-9-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMClient.h"

@implementation LLIMClient

- (id)initWithHost:(NSString *)host port:(int)port{
    if (self = [super initWithHost:host port:port]) {
        _messageQueue = [[LLSendMessageQueue alloc] init];
        _messageQueue.delegate = self;
       // [_messageQueue start];//登录成功以后，初始化消息队列才开始工作
    }

    return self;
}

- (void)onLoginSuccess{
    [super onLoginSuccess];
    
    [_messageQueue start];
}

- (void)onLogout{
    [super onLogout];
    
    [_messageQueue stop];
}


//收到消息回执
- (void)onRead:(NSString *)cmd status:(NSString *)status message:(NSDictionary *)message{
    
    [super onRead:cmd status:status message:message];
    // 这里只关心回执信息
    if ([cmd isEqualToString:@"text"] ||
        [cmd isEqualToString:@"image"] ||
        [cmd isEqualToString:@"voice"] ||
        [cmd isEqualToString:@"lucky"] ||
        [cmd isEqualToString:@"refuse"]) {
        
        [_messageQueue onRead:cmd status:status message:message];
    }
  
}

//发送一条消息
- (void)send:(LLSendMessageItem *)message{
    
    [_messageQueue addMessage:message];
    
}

//消息队列调用用
- (void)writeln:(NSString *)message{
    
    if(![self checkLogined]){
        DDLogError(@"还没有登陆，消息不能发送");
        return ;
    }
    
    
    if(![self isActive]){
        DDLogError(@"socket 链接断开");
    }
    
    [super writeln:message];
}


- (void)stop{
    [super stop];
    
    [_messageQueue stop];
}

- (void)dealloc{
    [self stop];
    DDLogWarn(@"%@ dealloc",self);
}


@end
