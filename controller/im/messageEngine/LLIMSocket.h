//
//  LLIMClient.h
//  Olla
//
//  Created by null on 14-9-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OllaSocket.h"
#import "LLIMClientProtocol.h"
#import "LLIMReceiveProtocol.h"


@interface LLIMSocket : NSObject<LLIMClientProtocol>{
}

@property(nonatomic,strong) OllaSocket *socket;
@property(nonatomic,assign,getter = isConnecting) BOOL connected;
@property(nonatomic,strong) NSString *host;
@property(nonatomic,assign) int port;


- (id)initWithHost:(NSString *)host port:(int)port;

- (void)onRead:(NSString *)cmd status:(NSString *)status message:(NSDictionary *)message;

- (int)port;

@end
