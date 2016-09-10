//
//  LLIMClientReconnect.m
//  Olla
//
//  Created by null on 14-9-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMClientReconnect.h"
#include "netinet/in.h"

@interface LLIMClientReconnect(){
    int count;
}

@end

@implementation LLIMClientReconnect

- (id)initWithHost:(NSString *)host port:(int)port{

    if (self = [super initWithHost:host port:port]) {
        self.stopped = NO;
        self.reconnecting = NO;
        count = 100;
    }
    
    return self;
}

- (void)start{
    [super start];
    self.stopped = NO;
}

- (void)stop:(long)waitTime{
    self.stopped = YES;
    [super stop:waitTime];
}

- (void)onDisconnect{
    [super onDisconnect];
    
    if (self.stopped) {
        return;
    }
    self.reconnecting = NO;
    [self reconnect];
}


- (void)reconnect{
    DDLogInfo(@"begin reconnect...");
    if (!self.reconnecting) {
         [self performSelectorInBackground:@selector(connect) withObject:nil];
    }
}

- (void)connect{

    while (![self isNetworkReachable]) {
        sleep(1);// 隔1s再试
    }
    while (count && !self.reconnecting) {//再次收到连接失败，进到onDisconnect以后再重连
        if ([self isActive]) {
            break;
        }
        DDLogError(@"reconnect count(%d)",100-count);
        self.reconnecting = YES;
        [self start];
        count--;
        sleep(1);
    }
    
}

- (BOOL)isNetworkReachable {
    // Create zero addy
    #if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin6_len = sizeof(zeroAddress);
    zeroAddress.sin6_family = AF_INET6;

    #else
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    #endif
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection);
}


//用来测试
- (void)disconnet{

    [self.socket disconnect];

}

@end
