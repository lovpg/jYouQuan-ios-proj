//
//  LLShareDataSouce.m
//  Olla
//
//  Created by Pat on 15/7/31.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLShareDataSource.h"
#import "LLShareMessage.h"

@interface LLShareDataSource () {
    GCDQueue *updateQueue;
    NSMutableDictionary *userCache;
    NSMutableDictionary *commentCache;
    NSMutableDictionary *shareCache;
}

@end

@implementation LLShareDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        updateQueue = [[GCDQueue alloc] initSerial];
        userCache = [[NSMutableDictionary alloc] init];
        shareCache = [[NSMutableDictionary alloc] init];
        commentCache = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void)loadAllNotifyMessages {
    [self loadNotifyMessagesWithAll:YES];
}

- (void)loadUnreadNotifyMessages {
    [self loadNotifyMessagesWithAll:NO];
}

- (void)loadNotifyMessagesWithAll:(BOOL)all {
    [updateQueue queueBlock:^{
        
        __block BOOL succeed1 = NO;
        
        __block NSArray *notifyDataSource = nil;
        
        if (all) {
         //   notifyDataSource = [[LLEaseModUtil sharedUtil] shareMessages];
        } else {
          //  notifyDataSource = [[LLEaseModUtil sharedUtil] unreadShareMessages];
        }
        
        if (notifyDataSource.count == 0) {
            [self shareNotifyMessagesDidChange:nil];
            return;
        }
        
        NSMutableArray *shareIdsArray = [NSMutableArray array];
        
        for (LLShareMessage *message in notifyDataSource) {
            if (message.shareId) {
                id cache = [shareCache objectForKey:message.shareId];
                if ([cache isKindOfClass:[LLShare class]]) {
                    message.share = cache;
                    continue;
                }
                if ([shareIdsArray containsObject:message.shareId]) {
                    continue;
                }
                [shareIdsArray addObject:message.shareId];
            }
        }
        
        if (shareIdsArray.count > 0) {
            NSMutableArray *tempArray = [NSMutableArray array];
            
            [shareIdsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempArray addObject:[NSString stringWithFormat:@"'%@'",obj]];
            }];
            
            NSString *where = [NSString stringWithFormat:@"shareId in (%@)", [tempArray componentsJoinedByString:@","]];
            NSArray *cacheShares = [LLShare selectWhere:where groupBy:nil orderBy:nil limit:nil];
            
            if (cacheShares.count > 0) {
                [cacheShares enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    LLShare *share = obj;
                    if ([shareIdsArray containsObject:share.shareId]) {
                        [shareIdsArray removeObject:share.shareId];
                    }
                    [shareCache setObject:share forKey:share.shareId];
                }];
                
                for (LLShareMessage *message in notifyDataSource) {
                    LLShare *share = [shareCache objectForKey:message.shareId];
                    if (share) {
                        message.share = share;
                    }
                }
            }
        }
        
        dispatch_semaphore_t semaphore1 = dispatch_semaphore_create(0);
        
        if (shareIdsArray.count > 0) {
            NSString *shareIds = [shareIdsArray componentsJoinedByString:@","];
            
            [[LLHTTPRequestOperationManager shareManager] POSTListWithURL:Olla_API_Share_BatchList parameters:@{@"shareIds":shareIds} modelType:[LLShare class] success:^(NSArray *datas, BOOL hasNext) {
                for (LLShare *model in datas) {
                    [shareCache setObject:model forKey:model.shareId];
                }
                
                for (LLShareMessage *message in notifyDataSource) {
                    message.share = [shareCache objectForKey:message.shareId];
                }
                
                [[GCDQueue highPriorityGlobalQueue] queueBlock:^{
                    [LLShare saveModels:datas];
                }];
                
                succeed1 = YES;
                dispatch_semaphore_signal(semaphore1);
            } failure:^(NSError *error) {
                succeed1 = NO;
                dispatch_semaphore_signal(semaphore1);
            }];
        } else {
            succeed1 = YES;
            dispatch_semaphore_signal(semaphore1);
        }
        
        dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
        if (!succeed1) {
            [self shareNotifyMessagesDidChange:nil];
            return;
        }
        
        __block BOOL succeed2 = NO;
        
        NSMutableArray *commentIdsArray = [NSMutableArray array];
        
        for (LLShareMessage *message in notifyDataSource) {
            if (message.commentId) {
                if ([commentCache objectForKey:message.commentId]) {
                    message.comment = [commentCache objectForKey:message.commentId];
                    continue;
                }
                if ([commentIdsArray containsObject:message.commentId]) {
                    continue;
                }
                [commentIdsArray addObject:message.commentId];
            }
        }
        
        if (commentIdsArray.count > 0) {
            NSMutableArray *tempArray = [NSMutableArray array];
            
            [shareIdsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempArray addObject:[NSString stringWithFormat:@"'%@'",obj]];
            }];
            
            NSString *where = [NSString stringWithFormat:@"commendId in (%@)", [tempArray componentsJoinedByString:@","]];
            NSArray *cacheComments = [LLComment selectWhere:where groupBy:nil orderBy:nil limit:nil];
            
            if (cacheComments.count > 0) {
                [cacheComments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    LLComment *comment = obj;
                    if ([commentIdsArray containsObject:comment.commentId]) {
                        [commentIdsArray removeObject:comment.commentId];
                    }
                    [commentCache setObject:comment forKey:comment.commentId];
                }];
                
                for (LLShareMessage *message in notifyDataSource) {
                    LLComment *comment = [commentCache objectForKey:message.commentId];
                    if (comment) {
                        message.comment = comment;
                        message.message = comment.content;
                    }
                }
            }
            
        }
        
        dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
        if (commentIdsArray.count > 0) {
            NSString *commentIds = [commentIdsArray componentsJoinedByString:@","];
            
            [[LLHTTPRequestOperationManager shareManager] POSTListWithURL:Olla_API_Post_Comment_BatchList parameters:@{@"commentIds":commentIds} modelType:[LLComment class] success:^(NSArray *datas, BOOL hasNext) {
                
                for (LLComment *model in datas) {
                    [commentCache setObject:model forKey:model.commentId];
                }
                
                for (LLShareMessage *message in notifyDataSource) {
                    message.comment = [commentCache objectForKey:message.shareId];
                }
                
                [[GCDQueue highPriorityGlobalQueue] queueBlock:^{
                    [LLComment saveModels:datas];
                }];
                
                succeed2 = YES;
                dispatch_semaphore_signal(semaphore2);
            } failure:^(NSError *error) {
                succeed2 = NO;
                dispatch_semaphore_signal(semaphore2);
            }];
        } else {
            succeed2 = YES;
            dispatch_semaphore_signal(semaphore2);
        }
        
        dispatch_semaphore_wait(semaphore2, DISPATCH_TIME_FOREVER);
        if (!succeed2) {
            [self shareNotifyMessagesDidChange:nil];
            return;
        }
        
        __block BOOL succeed3 = NO;
        
        NSMutableArray *uidArray = [NSMutableArray array];
        
        for (LLShareMessage *message in notifyDataSource) {
            if (message.uid) {
                if ([userCache objectForKey:message.uid]) {
                    message.user = [userCache objectForKey:message.uid];
                    continue;
                }
                if ([uidArray containsObject:message.uid]) {
                    continue;
                }
                [uidArray addObject:message.uid];
            }
        }
        
        if (uidArray.count > 0) {
            NSMutableArray *tempArray = [NSMutableArray array];
            
            [uidArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempArray addObject:[NSString stringWithFormat:@"'%@'",obj]];
            }];
            
            NSString *where = [NSString stringWithFormat:@"uid in (%@)", [tempArray componentsJoinedByString:@","]];
            NSArray *cacheUsers = [LLUser selectWhere:where groupBy:nil orderBy:nil limit:nil];
            
            if (cacheUsers.count > 0) {
                [cacheUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    LLUser *user = obj;
                    if ([uidArray containsObject:user.uid]) {
                        [uidArray removeObject:user.uid];
                    }
                    [userCache setObject:user forKey:user.uid];
                }];
                
                for (LLShareMessage *message in notifyDataSource) {
                    LLUser *user = [userCache objectForKey:message.uid];
                    if (user) {
                        message.user = user;
                    }
                }
            }
            
        }
        
        dispatch_semaphore_t semaphore3 = dispatch_semaphore_create(0);
        if (uidArray.count > 0) {
            NSString *uids = [uidArray componentsJoinedByString:@","];
            
            [[LLHTTPRequestOperationManager shareManager] POSTListWithURL:Olla_API_Profiles parameters:@{@"uids":uids} modelType:[LLUser class] success:^(NSArray *datas, BOOL hasNext) {
                for (LLUser *model in datas) {
                    [userCache setObject:model forKey:model.uid];
                }
                
                for (LLShareMessage *message in notifyDataSource) {
                    LLUser *user = [userCache objectForKey:message.uid];
                    message.user = user;
                }
                
                [[GCDQueue highPriorityGlobalQueue] queueBlock:^{
                    [LLUser saveModels:datas];
                }];
                
                succeed3 = YES;
                dispatch_semaphore_signal(semaphore3);
            } failure:^(NSError *error) {
                succeed3 = NO;
                dispatch_semaphore_signal(semaphore3);
            }];
        } else {
            succeed3 = YES;
            dispatch_semaphore_signal(semaphore3);
        }
        
        dispatch_semaphore_wait(semaphore3, DISPATCH_TIME_FOREVER);
        if (!succeed3) {
            [self shareNotifyMessagesDidChange:nil];
            return;
        }
        
        [self shareNotifyMessagesDidChange:notifyDataSource];
    }];
}

- (void)shareNotifyMessagesDidChange:(NSArray *)notifyDataSource {
    [[GCDQueue mainQueue] queueBlock:^{
        if ([self.delegate respondsToSelector:@selector(shareNotifyMessagesDidChange:)]) {
            [self.delegate shareNotifyMessagesDidChange:notifyDataSource];
        }
    }];
}


@end
