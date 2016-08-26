//
//  LLLoginDAO.h
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLoginAuth.h"
#import "LLLoginAuthDAO.h"
#import "LLUserDAO.h"
#import "LLMeDAO.h"

@interface LLLoginDAO : NSObject{
    LLLoginAuthDAO *loginAuthDAO;
    LLLoginDAO *loginDAO;
    LLUserDAO *userDAO;
    LLMeDAO *meDAO;
}

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password success:(void (^)(LLLoginAuth *loginAuth,LLUser *user))success fail:(void (^)(NSError *error))fail;

- (void)logoutSuccess:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

@end
