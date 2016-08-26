//
//  LLUserDAO.h
//  Olla
//
//  Created by null on 14-11-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLUser.h"

@interface LLUserDAO : NSObject

- (void)me:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail;

- (void)get:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail;

- (LLUser *)getUser:(NSString *)uid;

@end


