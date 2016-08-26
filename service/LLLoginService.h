//
//  LLLoginService.h
//  Olla
//
//  Created by null on 14-10-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLoginAuthDAO.h"
#import "LLLoginDAO.h"
#import "LLFirstLoginDAO.h"

@interface LLLoginService : NSObject{

    LLLoginDAO *loginDAO;
    LLFirstLoginDAO *firstLoginDAO;
}

@property(nonatomic,strong)  LLLoginAuthDAO *loginAuthDAO;

/**
 *  检查是否登录
 *
 *  @return
 */
- (BOOL)checkLogined;


/**
 *  这里做参数验证（合法性检查），登录成功以后使用 LLLoginAuthDAO存储
 *  登录成功以后，要拉取用户资料信息
 *
 *  @param userName
 *  @param password
 *
 *  @return
 */
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password success:(void (^)(LLLoginAuth *loginAuth,LLUser *user))success fail:(void (^)(NSError *error))fail;

/**
 *  退出登录
 *
 *  @return 
 */
- (BOOL)logout;


@end
