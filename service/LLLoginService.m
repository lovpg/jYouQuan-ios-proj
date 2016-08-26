//
//  LLLoginService.m
//  Olla
//
//  Created by null on 14-10-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLLoginService.h"

@implementation LLLoginService

- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.loginAuthDAO = [[LLLoginAuthDAO alloc] init];
        
        loginDAO = [[LLLoginDAO alloc] init];
        firstLoginDAO = [[LLFirstLoginDAO alloc] init];
    }
    return self;
}

- (BOOL)checkLogined{
    
//    NSString *easeUserName = [OllaKeychain passwordForService:@"Olla" account:@"easeUserName" error:NULL];
//    NSString *easeUserPassword = [OllaKeychain passwordForService:@"Olla" account:@"easeUserPassword" error:NULL];
    NSString *easeUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"ollaUserName"];
    NSString *easeUserPassword  = [[NSUserDefaults standardUserDefaults] objectForKey:@"ollaPassword"];
    
    if (easeUserName.length == 0 || easeUserPassword.length == 0)
    {
        return NO;
    }
    
    LLLoginAuth *loginAuth = [self.loginAuthDAO get];
    if (loginAuth) {
        if ([loginAuth.uid length]>0&&[loginAuth.sessionId length]>0) {
            return YES;
        }
    }
    
    return NO;
}


- (void)loginWithUserName:(NSString *)userName password:(NSString *)password
                  success:(void (^)(LLLoginAuth *loginAuth,LLUser *user))success
                     fail:(void (^)(NSError *error))fail
{
    
    [loginDAO loginWithUserName:userName
                       password:password
                        success:^(LLLoginAuth *auth,LLUser *user)
    {
        
        [firstLoginDAO setFirstLogin:YES];
        success(auth,user);
        
    } fail:^(NSError *error)
    {
        fail(error);
    }];
}

- (BOOL)logout{

    [loginDAO logoutSuccess:^(NSDictionary *userInfo) {
    } fail:^(NSError *error) {
        DDLogError([error description]);
    }];

    [firstLoginDAO clear];
    
    return YES;
}


@end


