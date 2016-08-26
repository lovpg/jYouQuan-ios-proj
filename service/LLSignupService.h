//
//  LLSignupService.h
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLoginAuthDAO.h"
#import "LLFirstLoginDAO.h"
#import "LLSignupDAO.h"
#import "LLUserDAO.h"
#import "LLMeDAO.h"

@interface LLSignupService : NSObject{
    
    LLLoginAuthDAO *loginAuthDAO;
    LLFirstLoginDAO *firstLoginDAO;
    LLSignupDAO *signupDAO;
    LLUserDAO *userDAO;
    LLMeDAO *meDAO;
}


- (void)signupWithUserName:(NSString *)userName
                  password:(NSString *)password
                  code:(NSString *)code
                    avatar:(UIImage *)image
                   success:(void (^)(LLLoginAuth *loginAuth))success fail:(void (^)(NSError *error))fail;

- (void)logout;

@end
