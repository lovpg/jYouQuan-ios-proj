//
//  LLIMContext.h
//  Olla
//
//  Created by null on 14-9-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLIMSender.h"
#import "LLMessageReceiveListenerImpl.h"

@interface LLIMContext : NSObject

@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) LLIMSender *imSender;
@property(nonatomic,assign,readonly) BOOL isActive;

- (id)initWithUid:(NSString *)uid token:(NSString *)token;

- (void)start;
- (void)stop;

@end
