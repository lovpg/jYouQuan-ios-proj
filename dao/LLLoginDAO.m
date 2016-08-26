//
//  LLLoginDAO.m
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLLoginDAO.h"


@implementation LLLoginDAO

- (instancetype)init{
    self = [super init];
    if (self) {
        
        loginAuthDAO = [[LLLoginAuthDAO alloc] init];
        userDAO = [[LLUserDAO alloc] init];//获取用户资料
        meDAO = [[LLMeDAO alloc] init];// 管理当前用户资料
        
    }
    return self;
}

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                  success:(void (^)(LLLoginAuth *loginAuth,LLUser *user))success
                     fail:(void (^)(NSError *error))fail
{
    
    //TODO:重大bug： 切换账号时，cookie里面有一份上个登录用户的SESSIONID信息，导致很多登录api直接返回该sessionId，导致服务端登录识别信息串号，具体原因还未查明！！
    [LLAppHelper clearCookies];
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:LBSLM_API_Login parameters:@{@"username":userName,@"password":password}
        success:^(id datas, BOOL hasNext)
    {
        DDLogInfo(@"登录信息：%@",datas);
        if (![datas isDictionary]) {
            DDLogError(@"登录信息返回不是字典");
            fail(nil);
            return;
        }
        LLLoginAuth *auth = [(NSDictionary *)datas modelFromDictionaryWithClassName:[LLLoginAuth class]];
        //meDAO使用preference存储资料（这句之前放service，MeDAO不好测试）
        [[LLPreference shareInstance] setUid:auth.uid];
        
        [[LLHTTPRequestOperationManager shareManager] setUserAuth:auth];
        [[LLHTTPWriteOperationManager shareWriteManager] setUserAuth:auth];

        NSArray *servers = [auth.server componentsSeparatedByString:@":"];
        if (servers.count == 2)
        {
            NSString *connectServer = servers.firstObject;
            NSString *writeServer = servers.lastObject;
            [[NSUserDefaults standardUserDefaults] setObject:connectServer forKey:@"com.between.evn.host"];
            [[NSUserDefaults standardUserDefaults] setObject:writeServer forKey:@"com.between.evn.write.host"];
            
//            [[LLHTTPRequestOperationManager shareManager] setBaseURL:[NSURL URLWithString:[LLAppHelper baseAPIURL]]];
//            [[LLHTTPWriteOperationManager shareWriteManager] setBaseURL:[NSURL URLWithString:[LLAppHelper writeOperationURL]]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:auth.imserver forKey:@"com.between.evn.imserver"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //同步信息,获取用户资料
        [userDAO get:auth.uid
            success:^(LLUser *user)
            {
                user.userName = auth.username;
                [meDAO set:user];//存储个人资料
                [loginAuthDAO add:auth];//存储授权信息
                success(auth,user);
            }
            fail:^(NSError *error)
            {
                fail(error);
            }];
        
    }
    failure:^(NSError *error)
    {
        fail(error);
    }];
    
}

- (void)logoutSuccess:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;{

    [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Logout parameters:nil success:^(id datas ,BOOL hasNext){
        [[[LLHTTPRequestOperationManager shareManager] operationQueue] cancelAllOperations];
        success(datas);
    } failure:^(NSError *error){
        DDLogError(@"logout error:%@",error);
        [[[LLHTTPRequestOperationManager shareManager] operationQueue] cancelAllOperations];
        fail(error);
    }];
    
    [[LLHTTPRequestOperationManager shareManager] setUserAuth:nil];
    [[LLPreference shareInstance] setUid:nil];
    [loginAuthDAO logout];
    
}

@end
