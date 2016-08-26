//
//  LLLoginAuth.m
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLLoginAuth.h"

@implementation LLLoginAuth

//服务端的number类型
- (void)setUid:(NSString *)uid{
    
    if ([uid isNumber]) {
        uid = [(NSNumber *)uid stringValue];
    }
    _uid = uid;
}

- (NSString *)toString
{
    NSString *username_ = [self.username stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    return [NSString stringWithFormat:@"uid=%@;token=%@;SESSIONID=%@;username=%@;server=%@;type=ios;ver=1",self.uid,self.token,self.sessionId,username_,self.server];
}

@end
