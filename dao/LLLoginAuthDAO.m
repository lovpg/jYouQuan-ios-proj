//
//  LLLoginAuthDAO.m
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLLoginAuthDAO.h"

// 使用keychin 存储
@implementation LLLoginAuthDAO

- (LLLoginAuth *)get{
    
    LLLoginAuth *auth = nil;
    NSString *authJSON = [OllaKeychain passwordForService:@"com.lbslm.tmiles" account:@"user.auth" error:nil];
    auth = [authJSON modelFromJSONWithClassName:[LLLoginAuth class]];
        
    if (!auth) {
        NSString *uid = [OllaKeychain passwordForService:@"com.lbslm" account:@"USERID" error:nil];
        NSString *username = [OllaKeychain passwordForService:@"com.lbslm" account:@"USERNAME" error:nil];;
        NSString *token = [OllaKeychain passwordForService:@"com.lbslm" account:@"TOKEN" error:nil];;
        NSString *sessionID = [OllaKeychain passwordForService:@"com.lbslm" account:@"SESSIONID" error:nil];;
        if([uid length]>0 && [token length]>0 && [sessionID length]>0){
            auth = [[LLLoginAuth alloc] init];
            auth.uid = uid;
            auth.username = username;
            auth.token = token;
            auth.sessionId = sessionID;
            
            [self add:auth];
        }
        
        //删除旧的授权信息
        [OllaKeychain deletePasswordForService:@"com.lbslm" account:@"USERID" error:nil];
        [OllaKeychain deletePasswordForService:@"com.lbslm" account:@"USERNAME" error:nil];
        [OllaKeychain deletePasswordForService:@"com.lbslm" account:@"TOKEN" error:nil];
        [OllaKeychain deletePasswordForService:@"com.lbslm" account:@"SESSIONID" error:nil];
        
    }
    
    return auth;
}

- (BOOL)add:(LLLoginAuth *)auth{
    NSString *authJSON = [auth mj_JSONString];
    [OllaKeychain setPassword:authJSON forService:@"com.lbslm.tmiles" account:@"user.auth" error:nil];
    return YES;
}

- (BOOL)logout{
    [OllaKeychain deletePasswordForService:@"com.lbslm.tmiles" account:@"user.auth" error:nil];
    return YES;
}

@end
