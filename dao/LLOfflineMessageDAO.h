//
//  LLOfflineMessageDAO.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLCommentNotify.h"

@interface LLOfflineMessageDAO : NSObject

- (LLUser *)offlineNewFansMessage;
- (void)addFansMessageWithUser:(LLUser *)user;
- (void)removeNewFansOfflineMessage;


- (NSMutableArray *)offlineNewCommentsMessage;
- (void)addCommentMessage:(LLCommentNotify *)message;
- (NSInteger)allCommentsMessageCount;
- (void)removeCommentOfflineMessageWithShareId:(NSString *)shareId;
- (void)removeAllCommentOfflineMessage;


@end
