//
//  LLChatRecord.h
//  Olla
//
//  Created by nonstriater on 14-7-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLMessage.h"
#import "LLSimpleUser.h"

// 一条记录由一条message和一个user组成
@interface LLChatRecord : NSObject

@property(nonatomic,assign) NSInteger unreadCount;
@property(nonatomic,assign) double timestamp;//ms,和java服务器保存一致
@property(nonatomic,strong) NSString *message;
@property(nonatomic,strong) NSString * fullMessage;// 完整的信息,交给IMdatasource时会用到

@property(nonatomic,strong) LLSimpleUser *user;

- (id)objectForKeyedSubscript:(id)key;

@end

