//
//  LLOfflineMessageService.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLCommentNotify.h"
#import "LLOfflineMessageDAO.h"
#import "LLUserDao.h"

@interface LLOfflineMessageService : NSObject{
    LLOfflineMessageDAO *offlineMessageDAO;
    LLUserDAO *userDAO ;
}

- (LLUser *)offlineNewFansMessage;
- (void)addFansMessageWithUid:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail;
- (void)addFansMessageWithUser:(LLUser *)user;
- (void)removeNewFansOfflineMessage;


- (LLCommentNotify *)lastCommentMessage;
- (NSMutableArray *)offlineNewCommentsMessage;
- (void)addCommentWithShareId:(NSString *)sid commentId:(NSString *)cid success:(void (^)(LLCommentNotify *user))success fail:(void (^)(NSError *error))fail;
- (void)addCommentMessage:(LLCommentNotify *)message;
- (NSInteger)allCommentsMessageCount;
- (void)removeCommentOfflineMessageWithShareId:(NSString *)shareId;
- (void)removeAllCommentOfflineMessage;


@end
