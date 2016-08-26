//
//  LLSendMessage.h
//  Olla
//
//  Created by null on 14-9-4.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^MessageSuccessBlock)(NSString *msgid,NSString *status, NSDictionary *messages);
typedef void (^MessageFailureBlock)(NSString *msgid,NSString *status, NSDictionary *messages);
typedef void (^MessageTimeoutBlock)( NSString *msgid,NSString *status, NSDictionary *messages);


@interface LLSendMessageItem : NSObject

@property(nonatomic,strong) NSString *msgid;
@property(nonatomic,strong) NSString *cmd;
@property(nonatomic,strong) NSString *message;
@property(nonatomic,assign) double time;//发送时间

@property(nonatomic,strong) MessageFailureBlock failBlock;
@property(nonatomic,strong) MessageSuccessBlock successBlock;

@end


