//
//  LLIMClient.m
//  Olla
//
//  Created by null on 14-9-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMSocket.h"

@interface LLIMSocket ()<OllaSocketDelegate>{

    id<LLIMReceiveProtocol> _receiveListener;
}

@end


@implementation LLIMSocket

- (id) initWithHost:(NSString *)host port:(int)port{

    if (self = [super init]) {
        _host = host;
        _port = port;
        _connected = NO;
        
        _socket = [[OllaSocket alloc] initWithDelegate:self];
        
    }
    return self;

}

- (void)setOnReceiveListener:(id<LLIMReceiveProtocol>)onReceiveListener;
{
    _receiveListener = onReceiveListener;

}

- (void)start{

    [self performSelectorInBackground:@selector(startInBackground) withObject:nil];
}

- (void)startInBackground{

    [_socket connectOnHost:_host port:_port];

}


- (void)stop{

    [self stop:0];
}

- (void)stop:(long)waitTime{
    if (waitTime>0) {
        sleep(waitTime);
    }
    
    _connected = NO;
    [_socket disconnect];
}

- (BOOL)isActive{
    
    if (_socket==NULL) {
        return NO;
    }
    
    return [_socket isValid] && self.connected;

}

- (void)onConnect{
    
    _connected = YES;
}
- (void)onDisconnect{
    
    _connected = NO;
}

- (int)port{
    if (!_connected) {
        return -1;
    }
    return [_socket portFromSocket];
}

- (void)send:(LLSendMessageItem *)message{
    DDLogInfo(@"to be overwrite");
}

- (void)writeln:(NSString *)message{
    NSString *line = [message stringByAppendingString:@"\n"];
    [_socket sendData:[line dataUsingEncoding:NSUTF8StringEncoding] tag:0];
}

// overwrite
- (void)onRead:(NSString *)cmd status:(NSString *)status message:(NSDictionary *)message{
    
    if ([cmd isEqualToString:@"receive"]) {
        [self writeln:[NSString stringWithFormat:@"ack %@",message[@"msgid"]]];
        [_receiveListener onReceive:message];
    }else if([cmd isEqualToString:@"news"]){
        [self writeln:[NSString stringWithFormat:@"ack %@",message[@"msgid"]]];
        [_receiveListener onNews:message];
    }else if([cmd isEqualToString:@"kick"]){
        [_receiveListener onKick:message];
    }else if([cmd isEqualToString:@"offline"]){
        int port = [message[@"port"] intValue];
        if (port != [self port]) {
            DDLogError(@"旧端口怎么会收到offline指令：message=%@,port=%d,之前的self.port=%d",message,port,[self port]);
#if DEBUG
            NSString *errMsg = [NSString stringWithFormat:@"旧端口怎么会收到offline指令：message=%@,port=%d,之前的self.port=%d",message,port,[self port]];
            [UIAlertView showWithTitle:nil message:errMsg cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
#endif
            return;
        }
        
        [_receiveListener onOffline:message];
       
    }    
}

- (void)socket:(OllaSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port{
    
    DDLogInfo(@"connect IM(%@:%d)",host,port);
    [self onConnect];
    
}


- (void)socketDidDisConnect:(OllaSocket *)socket withError:(NSError *)error{
    DDLogError(@"connect IM fail:%@",error);
    [self onDisconnect];
    
}

// onread()
- (void)socket:(OllaSocket *)socket didReadData:(NSData *)data tag:(long)tag{
    
    NSDictionary *info = [NSJSONSerialization  JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSString *cmd = info[@"cmd"];
    NSString *status = info[@"status"];
    
    [self onRead:cmd status:status message:info];
       
}




@end
