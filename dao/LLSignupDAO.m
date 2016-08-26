//
//  LLSignupDAO.m
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLSignupDAO.h"

@implementation LLSignupDAO

- (void)signupWithUserName:(NSString *)userName
                  password:(NSString *)password
                      code:(NSString *)code
                    avatar:(UIImage *)image
                   success:(void (^)(LLLoginAuth *loginAuth))success fail:(void (^)(NSError *error))fail
{
    if (!image)
    {
        DDLogError(@"图片参数不合法");
        fail(nil);
        return;
    }
    // [LLHTTPRequestOperationManager shareManager] -> [LLHTTPWriteOperationManager shareWriteManager]
    [[LLHTTPWriteOperationManager shareWriteManager]
     POSTWithURL:LBSLM_API_Signup
     parameters:@{@"username":userName,
                  @"password":password,
                  @"code":code
                  }
     images:@[image]
     success:^(NSDictionary *responseObject) {
        DDLogInfo(@"signup auth info = %@",responseObject);
        
        NSDictionary *data = responseObject[@"data"];
        
        if ([data isDictionary]) {
            LLLoginAuth *auth = [responseObject[@"data"] modelFromDictionaryWithClassName:[LLLoginAuth class]];
            //meDAO使用preference存储资料
            [[LLPreference shareInstance] setUid:auth.uid];
            [[LLHTTPRequestOperationManager shareManager] setUserAuth:auth];
            [[LLHTTPWriteOperationManager shareWriteManager] setUserAuth:auth];
            success(auth);
        } else {
            // 返回空数据时尝试等待和重新登录
            sleep(3);
            [[LLHTTPRequestOperationManager shareManager] GETWithURL:LBSLM_API_Login parameters:@{@"username":userName,@"password":password} success:^(id datas, BOOL hasNext) {
                if ([datas isDictionary]) {
                    LLLoginAuth *auth = [datas modelFromDictionaryWithClassName:[LLLoginAuth class]];
                    [[LLPreference shareInstance] setUid:auth.uid];
                    [[LLHTTPRequestOperationManager shareManager] setUserAuth:auth];
                    [[LLHTTPWriteOperationManager shareWriteManager] setUserAuth:auth];
                    success(auth);
                } else {
                    fail(nil);
                }
                
            } failure:^(NSError *error) {
                fail(error);
            }];
        }
        
    } failure:^(NSError *error) {
        fail(error);
    }];
    
}

@end
