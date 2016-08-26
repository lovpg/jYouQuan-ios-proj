//
//  LLOfflineMessageDAO.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLOfflineMessageDAO.h"

@implementation LLOfflineMessageDAO

- (LLUser *)offlineNewFansMessage{
    NSData *data = [[LLPreference shareInstance] valueForKey:@"newFans"];
    LLUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (![user isKindOfClass:LLUser.class]) {
        return nil;
    }
    
    return user;
}

- (void)addFansMessageWithUser:(LLUser *)user{
    NSData *data =[NSKeyedArchiver archivedDataWithRootObject:user];
    [[LLPreference shareInstance] setValue:data forKey:@"newFans"];
}

- (void)removeNewFansOfflineMessage{
    [[LLPreference shareInstance] removeValueForKey:@"newFans"];
}


// new comment message // ////////////////////////////////

- (NSMutableArray *)offlineNewCommentsMessage{
    
    NSData *data = [[LLPreference shareInstance] valueForKey:@"newComment"];
    NSMutableArray *comments = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (![comments isKindOfClass:NSArray.class]) {
        comments  = nil;
    }
    
    // 过滤重复的评论
    NSMutableArray *results = [NSMutableArray array];
    NSMutableArray *commentIds = [NSMutableArray array];
    for (LLCommentNotify *commentNotify in comments) {
        if ([commentIds containsObject:commentNotify.comment.commentId]) {
            continue;
        }
        [results addObject:commentNotify];
        [commentIds addObject:commentNotify.comment.commentId];
    }
    return results;
    
}

- (void)addCommentMessage:(LLCommentNotify *)message{
    NSMutableArray *messages = [self offlineNewCommentsMessage];
    [messages addObject:message];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[messages copy]];
    [[LLPreference shareInstance] setValue:data forKey:@"newComment"];
}

- (NSInteger)allCommentsMessageCount{
    
    return [[self offlineNewCommentsMessage] count];
    
}

- (void)removeCommentOfflineMessageWithShareId:(NSString *)shareId{
    
    @synchronized(self){
        
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        NSMutableArray *comments = [self offlineNewCommentsMessage];
        
        for (LLCommentNotify *commentNotify in comments) {
            if ([commentNotify.share.shareId isEqualToString:shareId]) {
                [set addIndex:[comments indexOfObject:commentNotify]];
            }
        }
        
        [comments removeObjectsAtIndexes:set];
        
        //同步下数据
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[comments copy]];
        [[LLPreference shareInstance] setValue:data forKey:@"newComment"];
    }

    
}

- (void)removeAllCommentOfflineMessage{

    [[LLPreference shareInstance] removeValueForKey:@"newComment"];
}


@end


