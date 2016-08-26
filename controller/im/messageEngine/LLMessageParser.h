//
//  LLMessageParser.h
//  Olla
//
//  Created by null on 14-12-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLMessageParser : NSObject

// 发送的消息封包
//- (NSString *)sendTextMessageWithUid:(NSString *)uid msgID:(NSString *)msgid text:(NSString *)text;
//- (NSString *)sendImageMessageWithUid:(NSString *)uid msgID:(NSString *)msgid URLString:(NSString *)urlString;
//- (NSString *)sendVoiceMessageWithUid:(NSString *)uid msgID:(NSString *)msgid URLString:(NSString *)urlString;
//
//// 接收的im回执消息解包
//- (NSDictionary *)receiveImMessageResponse:(NSString *)responseString;
//
//// 接收的消息解包
//- (NSDictionary *)receiveTextMessage:(NSString *)message;
//- (NSDictionary *)receiveImageMessage:(NSString *)message;
//- (NSDictionary *)receiveVoiceMessage:(NSString *)message;
//
//
////news通知
//- (NSDictionary *)receiveCommentNotificationMessage:(NSString *)message;
//- (NSDictionary *)receiveNewFansNotificationMessage:(NSString *)message;
//- (NSDictionary *)receiveDarkRoomNotificationMessage:(NSString *)message;
//- (NSDictionary *)receiveForceOfflineNotificationMessage:(NSString *)message;
//
//
//// lucky
///**
//lucky login/logout
//
// 我拒绝匹配到的用户 refuse
// 
// 收到匹配用户资料
// 收到我被拒绝
// 
// */
//- (NSString *)luckyLoginMessage;
//- (NSString *)luckyLogoutMessage;
//- (NSString *)luckyRefuseMessageWithUid:(NSString *)uid;
//- (NSString *)luckyNextMessage;
//- (NSDictionary *)receiveLuckyLoginResponse:(NSString *)responseString;
//- (NSDictionary *)receiveLuckyLogoutResponse:(NSString *)responseString;
//- (NSDictionary *)receiveLuckyNextResponse:(NSString *)responseString;
//- (NSDictionary *)receiveLuckyRefuseResponse:(NSString *)responseString;
//- (NSDictionary *)receiveLuckyUserInfo:(NSString *)userInfo;
//- (NSDictionary *)receiveLuckyDownInfo:(NSString *)info;


@end


