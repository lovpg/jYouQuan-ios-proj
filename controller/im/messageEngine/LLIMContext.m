//
//  LLIMContext.m
//  Olla
//
//  Created by null on 14-9-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMContext.h"

@interface LLIMContext(){
    LLIMClient *client;
    LLMessageReceiveListenerImpl *lisenter;
}

@end

@implementation LLIMContext

- (id)initWithUid:(NSString *)uid token:(NSString *)token{
    if (self=[super init]) {
        self.uid = uid;
        self.token = token;
        
        [self setup];
    }
    return self;
}

-(BOOL)isActive{
    return [_imSender isActive];
}

- (void)setup{
  
    client = [[LLIMClient alloc] initWithHost:Olla_API_IM_URL port:5180];
    lisenter = [[LLMessageReceiveListenerImpl  alloc] init];
    [client setOnReceiveListener:lisenter];
    _imSender = [[LLIMSender alloc] initWithIMClient:client];
    
}

- (void)start{
    //[self setup];
    
    if ([self.uid length]==0 || [self.token length]==0) {
        DDLogError(@"IM启动参数不合法, uid,token不能为空");
        return;
    }
    
    client.uid = self.uid;
    client.password = self.token;
    [client start]; 
}


- (void)stop{

    [client stop];
    self.uid = nil;
    self.token = nil;

    
}

- (void)dealloc{
    DDLogWarn(@"%@ dealloc",self);
    
    [self stop];
    client = nil;
    lisenter = nil;
    _imSender = nil;
    
}



@end
