//
//  LLSignupService.m
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLSignupService.h"

@implementation LLSignupService

-(instancetype)init{
    if(self = [super init]){
        
        signupDAO = [[LLSignupDAO alloc] init];
        loginAuthDAO = [[LLLoginAuthDAO alloc] init];
        firstLoginDAO = [[LLFirstLoginDAO alloc] init];
        userDAO = [[LLUserDAO alloc] init];
        meDAO = [[LLMeDAO alloc] init];
        
    }
    return self;
}

- (void)signupWithUserName:(NSString *)userName
                  password:(NSString *)password
                  code:(NSString *)code
                    avatar:(UIImage *)image
                   success:(void (^)(LLLoginAuth *loginAuth))success
                      fail:(void (^)(NSError *error))fail
{
    
    //TODO:重大bug： 切换账号时，cookie里面有一份上个登录用户的SESSIONID信息，导致很多登录api直接返回该sessionId，导致服务端登录识别信息串号，具体原因还未查明！！
//    [LLAppHelper clearCookies];
    [signupDAO signupWithUserName:userName
                            password:password
                               code:code
                           avatar:image
                          success:^(LLLoginAuth *loginAuth)
    {
 
        // 修改写操作 [LLHTTPRequestOperationManager shareManager] => [LLHTTPWriteOperationManager shareWriteManager]
        [[LLHTTPRequestOperationManager shareManager] setUserAuth:loginAuth];
        [[LLHTTPWriteOperationManager shareWriteManager] setUserAuth:loginAuth];
        //同步信息,获取用户资料
        [userDAO get:loginAuth.uid success:^(LLUser *user){
            user.userName = userName;
            [meDAO set:user];//存储个人资料
            [loginAuthDAO add:loginAuth];//存储授权信息
            [firstLoginDAO setFirstLogin:YES];
            success(loginAuth);
        } fail:^(NSError *error) {
            success(loginAuth);
        }];
        
    } fail:^(NSError *error) {
        fail(error);
    }];

}

- (void)logout {
    [loginAuthDAO logout];
    [firstLoginDAO clear];
}


@end
