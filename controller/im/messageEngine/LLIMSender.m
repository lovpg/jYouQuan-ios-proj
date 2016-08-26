//
//  LLIMSender.m
//  Olla
//
//  Created by null on 14-9-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMSender.h"
#import "LLLocalCommandContext.h"

static NSString *localCommandPrefix = @"!set ";

@interface LLIMSender (){
    
    __weak LLIMClient *_imClient;//不需要强引用，imClient由LLIMContext持有
    LLLocalCommandContext *lcc;
}


@end

@implementation LLIMSender

- (id)initWithIMClient:(LLIMClient *)client{
    if (self= [super init]) {
        _imClient = client;
        lcc = [[LLLocalCommandContext alloc] init];
    }
    return self;
}

- (LLIMClient *)getClient{

    return _imClient;
}

- (BOOL)isActive{
    return [_imClient isActive];
}

+ (LLSendMessageItem *)messageItemWithCmd:(NSString *)cmd msgid:(NSString *)msgid message:(NSString *)message successBlock:success failureBlock:failure{
    
    LLSendMessageItem *item = [[LLSendMessageItem alloc] init];
    if (!msgid) {
        msgid = cmd;
    }
    item.msgid = msgid;
    item.cmd = cmd;
    item.message = message;
    
    item.successBlock = success;
    item.failBlock = failure;
    
    return item;
}


- (void)sendACK:(NSString *)msgid onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{
    NSString *ack = [NSString stringWithFormat:@"ack %@",msgid];
    [_imClient send:[[self class] messageItemWithCmd:@"ack" msgid:msgid message:ack successBlock:success failureBlock:failure]];
}


- (void)sendTextWithUid:(NSString *)uid msgid:(NSString *)msgid content:(NSString *)content onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{

    if ([uid isEqualToString:@"10000"] && [[content dictionaryRepresentation][@"message"] hasPrefix:localCommandPrefix]) {
        
        NSString *message = [content dictionaryRepresentation][@"message"];
        NSArray *commands = [message componentsSeparatedByString:@" "];
        NSString *command,*option;
        if ([commands count]>1) {
            command = [commands objectAtIndex:1];
        }
        if ([commands count]>2) {
            option = [commands objectAtIndex:2];
        }
        [lcc onReciveCommand:command option:option];
        
        return;
    }
    
    NSString *text = [NSString stringWithFormat:@"text %@ %@ %@",uid,msgid,content];
    [_imClient send:[[self class] messageItemWithCmd:@"text" msgid:msgid message:text successBlock:success failureBlock:failure]];
    
}

- (void)sendImageWithUid:(NSString *)uid msgid:(NSString *)msgid content:(NSString *)content onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{

    NSString *text = [NSString stringWithFormat:@"image %@ %@ %@",uid,msgid,content];
    [_imClient send:[[self class] messageItemWithCmd:@"image" msgid:msgid message:text successBlock:success failureBlock:failure]];
    
}


- (void)sendAudioWithUid:(NSString *)uid msgid:(NSString *)msgid content:(NSString *)content onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{

    //TODO:imparse
    //NSString *text = [[IMParse shareInstance] textMessageWithUid:uid msgid:msgid content:content];
    NSString *text = [NSString stringWithFormat:@"voice %@ %@ %@",uid,msgid,content];
    [_imClient send:[[self class] messageItemWithCmd:@"voice" msgid:msgid message:text successBlock:success failureBlock:failure]];
    
}


- (void)logout{
    [self logoutOnSuccess:nil onFail:nil];
}

//万一有消息在消息队列里发不出去，会阻止logout指令执行
- (void)logoutOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{

    NSString *text = [NSString stringWithFormat:@"logout"];
    [_imClient send:[[self class] messageItemWithCmd:@"logout" msgid:nil message:text successBlock:success failureBlock:failure]];
    
}


- (void)luckyLoginOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{
    
    [_imClient send:[[self class] messageItemWithCmd:@"lucky" msgid:nil message:@"lucky login" successBlock:success failureBlock:failure]];

}

- (void)luckyLogoutOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{

     [_imClient send:[[self class] messageItemWithCmd:@"lucky" msgid:nil message:@"lucky logout" successBlock:success failureBlock:failure]];
}

- (void)luckyNextOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{
    [_imClient send:[[self class] messageItemWithCmd:@"lucky" msgid:nil message:@"lucky next" successBlock:success failureBlock:failure]];
}

- (void)refuseUid:(NSString *)uid onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure{
    NSString *message = [NSString stringWithFormat:@"refuse %@",uid];
    [_imClient send:[[self class] messageItemWithCmd:@"refuse" msgid:nil message:message successBlock:success failureBlock:failure]];
}


- (void)dealloc{
    DDLogWarn(@"%@ dealloc",self);
}


@end
