//
//  LLEMUserDAO.h
//  Olla
//
//  Created by Pat on 15/3/20.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLUser.h"

@protocol LLEMUserDAODelegate <NSObject>

- (void)getUserInfoFinish;
- (void)getUserInfoFail;

@end

@interface LLEMUserDAO : NSObject

@property (nonatomic, assign) id<LLEMUserDAODelegate> delegate;

- (void)get:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail;
- (void)getUsersWithIds:(NSArray *)userIds;

- (LLUser *)userInfoWithUID:(NSString *)uid;

@end
