//
//  LLIMClientReconnect.h
//  Olla
//
//  Created by null on 14-9-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMClientLogin.h"

// 重连
@interface LLIMClientReconnect : LLIMClientLogin

@property(nonatomic,assign) BOOL stopped;//是否主动断开(如登出登陆)
@property(nonatomic,assign) BOOL reconnecting;//正在重连

- (void)disconnet;

@end
