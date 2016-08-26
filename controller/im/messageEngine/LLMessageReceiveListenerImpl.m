//
//  LLMessageReceiveListenerImpl.m
//  Olla
//
//  Created by null on 14-9-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLMessageReceiveListenerImpl.h"
//#import "LLLuckyMatchViewController.h"

@implementation LLMessageReceiveListenerImpl

- (instancetype)init{
    if (self=[super init]) {
        blockService = [[LLBLockService alloc] init];
    }
    return self;
}

- (void)onReceive:(NSDictionary *)map{
    DDLogInfo(@"reveive message:%@",map);
    
    NSString *cmdType = map[@"type"];
    if ([cmdType isEqualToString:@"text"]||
        [cmdType isEqualToString:@"image"]||
        [cmdType isEqualToString:@"voice"]) {
        
        [self onIm:map];
        
    }else if([cmdType isEqualToString:@"lucky"]){
    
        [self onLucky:map];
        
    }else if([cmdType isEqualToString:@"refuse"]){
        
        [self onRefuse:map];
        
    }else if([cmdType isEqualToString:@"luckyDown"]){//对方next后，我收到的消息
        
        [self luckyDown:map];
    
    }else{
        DDLogError(@"unkown cmd type :%@",map);
    }

}

- (void)onIm:(NSDictionary *)map{

    if (![self checkIMMessage:map]) {
        return;
    }
    
    NSString *ouid = nil;
    if ([map[@"uid"] isNumber]) {
        ouid = [map[@"uid"] stringValue];
    }else if([map[@"uid"] isString]){
        ouid = map[@"uid"];
    }
    if (!ouid) {
        DDLogError(@"ouid must not be nil: message= %@",map);
        return ;
    }
    
    @synchronized(self){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaNewMessageToChatsNotification" object:nil userInfo:@{@"message":map}];
        
    }
}


- (BOOL)checkIMMessage:(NSDictionary *)message{

    NSString *userId = message[@"uid"];
    if (!userId) {
        DDLogError(@"收到的消息，uid为nil");
        return NO;
    }

    NSDictionary *messageDict = [message[@"data"] dictionaryRepresentation];
    if (![messageDict isDictionary]) {
        DDLogError(@"收到的消息格式，不是字典");
        return NO;
    }
    
    NSString *msgid = message[@"msgid"];
    if (!msgid) {
        DDLogError(@"收到的消息msgid为空");
        return NO;
    }

    return YES;

}


- (void)onNews:(NSDictionary * )map{
    DDLogInfo(@"reveive news:%@",map);
    
    NSString *type = map[@"type"];
    if ([type isEqualToString:@"dark"]) {
    
        NSDictionary *dict = [map[@"data"] dictionaryRepresentation];
        if (![dict isDictionary]) {
            DDLogError(@"Dark,服务器数据格式错误：%@",map);
            return;
        }
        
        BOOL isBlocked = [dict[@"add"] boolValue];//如果是false，就是解除
        [blockService setBlocked:isBlocked];
        
    }else if ([type isEqualToString:@"comment"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaNewCommentNotification" object:nil userInfo:map[@"data"]];
        
        
    }else if ([type isEqualToString:@"fans"]) {
       
        NSDictionary *dict = [map[@"data"] dictionaryRepresentation];
        if (![dict isDictionary]) {
            DDLogError(@"新粉丝提醒,服务器数据格式错误:%@",map);
            return;
        }
        
        NSString *uid = dict[@"ouid"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaNewFansNotification" object:nil userInfo:@{@"uid":uid}];
        
    }
 
}


- (void)onOffline:(NSDictionary *)map{
    DDLogInfo(@"另一台手机用这个账号登陆,这台手机下线处理:%@",map);
    [UIAlertView showWithTitle:nil message:@"this account will logout from another device" cancelButtonTitle:nil otherButtonTitles:@[@"got it"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
       // [(AppDelegate *)[[UIApplication sharedApplication] delegate] logout];
    }];
}

- (void)onKick:(NSDictionary *)map{
    DDLogInfo(@"reveive kick:%@",map);
}


- (void)onLucky:(NSDictionary *)map{
    DDLogInfo(@"receive lucky user:%@",map);
//    UIViewController *luckyMatchVC = [(LLAppDelegate *)[[UIApplication sharedApplication] delegate] currentViewController];
//    if ([luckyMatchVC isKindOfClass:[LLLuckyMatchViewController class]]) {
//        NSDictionary *userInfo = [(NSString *)map[@"data"] dictionaryRepresentation];
//        if (![userInfo isDictionary]) {
//            DDLogError(@"数据非法:%@",map);
//            return;
//        }
//        LLSimpleUser *user = [userInfo modelFromDictionaryWithClassName:[LLSimpleUser class]];
//        [(LLLuckyMatchViewController *)luckyMatchVC luckyMatchWithUser:user];
//    }
}


- (void)luckyDown:(NSDictionary *)map{

//    DDLogInfo(@"对方选择了lucky next:%@",map);
//    UIViewController *luckyMatchVC = [(LLAppDelegate *)[[UIApplication sharedApplication] delegate] currentViewController];
//    if ([luckyMatchVC isKindOfClass:[LLLuckyMatchViewController class]]) {
//        NSString  *uid = [(NSNumber *)map[@"uid"] stringValue];
//        [(LLLuckyMatchViewController *)luckyMatchVC luckyDownByUser:uid];
//    }
    
}

- (void)onRefuse:(NSDictionary *)map{

    DDLogInfo(@"refused by user:%@",map);
//    UIViewController *luckyMatchVC = [(LLAppDelegate *)[[UIApplication sharedApplication] delegate] currentViewController];
//    if ([luckyMatchVC isKindOfClass:[LLLuckyMatchViewController class]]) {
//        NSString  *uid = [(NSNumber *)map[@"uid"] stringValue];
//        [(LLLuckyMatchViewController *)luckyMatchVC refusedByUser:uid];
//    }
}


@end
