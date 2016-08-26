//
//  LLSendMessageQeueu.m
//  Olla
//
//  Created by null on 14-9-4.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLSendMessageQueue.h"
#import "LLSendMessageItem.h"

#define TIME_OUT 2.f // 10s

@interface LLSendMessageQueue(){
   
    NSMutableArray *_messages;
    NSThread *_sendMessageThread;
    dispatch_semaphore_t semaphare;
    
    LLSendMessageItem *lastMessage;
    
    int retryCount;
}

@end

/**
 1. 无消息时休眠等待
 2. 发一条消息时，要等到有回执信息，或超时
 3. 如果之前的发送线程饥饿等待中，这时候往队列中添加一条消息，要唤醒线程工作
 */

@implementation LLSendMessageQueue

- (id)init{
    if (self = [super init]) {
        _messages = [NSMutableArray array];
        retryCount = 10;
    }
    return self;
}

- (void)start{
    
    if(_sendMessageThread){
        [_sendMessageThread cancel];
        _sendMessageThread = nil;
    }
    
    _sendMessageThread = [[NSThread alloc] initWithTarget:self selector:@selector(internalStart) object:nil];
    [_sendMessageThread setName:@"com.olla.im.sendthread"];
    [_sendMessageThread start];
    
}

- (void)stop{

    if (_sendMessageThread) {
        [_sendMessageThread cancel];
    }
}

- (NSInteger)count{
    return [_messages count];
}

// 生产者
- (void)addMessage:(LLSendMessageItem *)message{
    
    message.time = [[NSDate date] timeIntervalSinceNow];
    @synchronized(self){
        [_messages addObject:message];
        DDLogWarn(@"%@ add a Message:%@",self,message.message);
    }
}

//消费者
- (void)internalStart{
    
    @autoreleasepool {
        
        DDLogInfo(@"send message queue thread run");
        
        [self sendMessage];
    
        DDLogError(@"send message queue thread exits");
        
    }
}

- (BOOL)runloopShouldExit{
 
    return NO;
}

//发送一条消息，如果超时，接着再发
- (void)sendMessage{
    
    while (1) {
        
        if ([_sendMessageThread isCancelled]) {
            break;
        }
        
        [self sendNext];
        
        usleep(500*1000);//500ms
    }
}

- (void)sendNext{
    
    if ([_messages count]==0) {
        //DDLogWarn(@"消息队列无消息，发送线程休眠等待一会儿再试");
        return;
    }
    
    LLSendMessageItem *message = nil;
    @synchronized(self){
        message = [_messages firstObject];
    }

    if(message && ![self isSending:message]){
        DDLogWarn(@"%@ send a Message:%@",self,message.message);
        [self send:message];
    }
    
    double now = [[NSDate date] timeIntervalSince1970];
    double timeoffset = now - lastMessage.time;
    if (timeoffset>TIME_OUT) {//服务器没返回 or 网络中断
        
        if (retryCount>0) {
            DDLogInfo(@"消息超时,消息重发一遍：%@, count=%d",message.message,10-retryCount);
            retryCount--;
            [self send:message];// 超时的行为待定？超时3次就提示用户错误，然后重发
        }else{
            DDLogInfo(@"超时10次,停止重发,并从消息队列中移除该消息：%@",message.message);
            retryCount = 10;
            if (lastMessage.failBlock) {
                lastMessage.failBlock(lastMessage.msgid,@"超时",@{});
            }
            @synchronized(self){
                [_messages removeObject:lastMessage];
            }
        } 
    }

}

- (BOOL)isSending:(LLSendMessageItem *)message{

    if (!lastMessage) {
        return NO;
    }
    return (message == lastMessage);
}


- (void)send:(LLSendMessageItem *)message{
    
    lastMessage = message;
    [lastMessage setTime:[[NSDate date] timeIntervalSince1970]];
    
    NSString *msg = message.message;
    [_delegate writeln:msg];

}



//当收到一条消息回执，从队列中移除
- (void)onRead:(NSString *)cmd status:(NSString *)status message:(NSDictionary *)message{
    
    NSString *msgid = message[@"msgid"];
    if (!msgid) {
        msgid = cmd;
    }
    
    if (lastMessage && [msgid isEqualToString:lastMessage.msgid]) {
        DDLogInfo(@"消息收到回执:msg=%@,回执信息:%@",lastMessage.message,message);
        
        if ([message[@"status"] isEqualToString:@"200"]||[message[@"status"] isEqualToString:@"UserOffline"]) {
            lastMessage.successBlock(msgid,@"200",message);
        }else{
            lastMessage.failBlock(msgid,message[@"status"],message);
        }
        
        @synchronized(self){ 
            DDLogWarn(@"%@ remove a Message:%@",self,msgid);
            [_messages removeObject:lastMessage];
            retryCount=10;
        }

    }
  
}



@end


