//
//  OllaAuthContext.m
//  Olla
//
//  Created by null on 14-10-18.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaAuthContext.h"

@implementation OllaAuthContext

@synthesize uid = _uid;
@synthesize username = _username;
@synthesize token = _token;
@synthesize sessionID = _sessionID;


- (NSString *)toString{
    return [NSString stringWithFormat:@"uid=%@;token=%@;SESSIONID=%@;username=%@",self.uid,self.token,self.sessionID,self.username];
}

+ (OllaAuthContext *)authContextWithString:(NSString *)string{

    NSArray *array = [string componentsSeparatedByString:@";"];
    if ([array count]!=4) {
        DDLogError(@"auth info 没有4项：%@",string);
        return nil;
    }
    OllaAuthContext *auth = [[OllaAuthContext alloc] init];
    auth.uid = array[0];
    auth.token = array[1];
    auth.sessionID = array[2];
    auth.username = array[3];
    
    return auth;
    
}

@end


