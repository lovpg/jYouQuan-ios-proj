//
//  LLSignupDAO.h
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLoginAuth.h"

@interface LLSignupDAO : NSObject

- (void)signupWithUserName:(NSString *)userName
                  password:(NSString *)password
                      code:(NSString *)code
                    avatar:(UIImage *)image success:(void (^)(LLLoginAuth *loginAuth))success fail:(void (^)(NSError *error))fail;

@end
