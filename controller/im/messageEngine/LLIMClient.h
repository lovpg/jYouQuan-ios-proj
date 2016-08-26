//
//  LLIMClient.h
//  Olla
//
//  Created by null on 14-9-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMClientReconnect.h"
#import "LLSendMessageQueue.h"

@interface LLIMClient : LLIMClientReconnect

@property(nonatomic,strong) LLSendMessageQueue *messageQueue;

@end
