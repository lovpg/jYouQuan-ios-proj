//
//  LLOfflineMessageService.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLOfflineMessageService.h"

@implementation LLOfflineMessageService

- (instancetype)init{
    if (self=[super init]) {
        offlineMessageDAO = [[LLOfflineMessageDAO alloc] init];
        userDAO = [[LLUserDAO alloc] init];
    }
    return self;
}

- (LLUser *)offlineNewFansMessage{

    return [offlineMessageDAO offlineNewFansMessage];
}

- (void)addFansMessageWithUid:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail{
    
    [userDAO get:uid success:^(LLUser *user) {
        
        [self addFansMessageWithUser:user];
        success(user);
        
    } fail:^(NSError *error) {
        fail(error);
    }];
    
}


- (void)addFansMessageWithUser:(LLUser *)user{
    [offlineMessageDAO addFansMessageWithUser:user];
}


- (void)removeNewFansOfflineMessage{
    [offlineMessageDAO removeNewFansOfflineMessage];
}



// //////////////////////////////////////

- (NSMutableArray *)offlineNewCommentsMessage{
    
    return [offlineMessageDAO offlineNewCommentsMessage];
}

- (LLCommentNotify *)lastCommentMessage{
    return [[self offlineNewCommentsMessage] lastObject];
}

- (void)addCommentWithShareId:(NSString *)sid commentId:(NSString *)cid success:(void (^)(LLCommentNotify *cmt))success fail:(void (^)(NSError *error))fail{

    LLCommentNotify *cn = [[LLCommentNotify alloc] init];
    [GCDHelper dispatchBlock:^{
        
        __block LLComment *comment = nil;
        [LLHTTPRequestOperationManager
         GETSync:Olla_API_Share_CommentDetail  params:@{@"commentId":cid} complete:^(NSDictionary *respond,NSError *error){
             if (error) {
                 DDLogError(@"comment message error：%@",error);
                 fail(error);
                 return ;
             }
             comment =  [respond modelFromDictionaryWithClassName:[LLComment class]];
         }];
        
        // share详情信息,如果有缓存，去缓存里面查询share信息
        __block LLShare *share = nil;
        [LLHTTPRequestOperationManager GETSync:Olla_API_Share_Detail params:@{@"shareId":sid}   complete:^(NSDictionary *respond,NSError *error){
            if (error) {
                DDLogError(@"share message error：%@",error);
                fail(error);
                return ;
            }
            share = [respond modelFromDictionaryWithClassName:[LLShare class]];
        } ];
        
        if (!share || !comment) {
            return ;
        }
        
        cn.comment = comment;
        cn.share = share;
        
        [self addCommentMessage:cn];
  
    } completion:^{
        success(cn);//要在主线程上执行
    }];

}

- (void)addCommentMessage:(LLCommentNotify *)message{
    [offlineMessageDAO addCommentMessage:message];
}

- (NSInteger)allCommentsMessageCount{
    return [offlineMessageDAO allCommentsMessageCount];
}

- (void)removeCommentOfflineMessageWithShareId:(NSString *)shareId{
    return [offlineMessageDAO removeCommentOfflineMessageWithShareId:shareId];
}

- (void)removeAllCommentOfflineMessage{
    [offlineMessageDAO removeAllCommentOfflineMessage];
}


@end
