//
//  LLEMUserDAO.m
//  Olla
//
//  Created by Pat on 15/3/20.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLEMUserDAO.h"
#import "LLHTTPRequestOperationManager.h"
@interface LLEMUserDAO () {
    NSMutableArray *queryCache;
    NSMutableDictionary *userCache;
    NSLock *lock;
}

@end

@implementation LLEMUserDAO

- (instancetype)init
{
    self = [super init];
    if (self) {
        queryCache = [[NSMutableArray alloc] init];
        userCache = [[NSMutableDictionary alloc] init];
        lock = [[NSLock alloc] init];
    }
    return self;
}

- (BOOL)existUID:(NSString *)uid {
    [lock lock];
    BOOL exist = [queryCache containsObject:uid];
    [lock unlock];
    return exist;
}

- (void)setUid:(NSString *)uid {
    [lock lock];
    
    if (![queryCache containsObject:uid]) {
        [queryCache addObject:uid];
    }
    
    [lock unlock];
}

- (void)removeUid:(NSString *)uid {
    [lock lock];
    
    if ([queryCache containsObject:uid]) {
        [queryCache removeObject:uid];
    }
    
    [lock unlock];
}

- (void)get:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail {
    
    if ([self existUID:uid]) {
        return;
    }
    
    [self setUid:uid];
    
    __weak typeof(self) weakSelf = self;
    
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_ProfileOther parameters:@{
                                                                                                @"uid":uid, LLAPICacheIgnoreParamsKey:@(1)} modelType:[LLUser class] needCache:YES success:^(OllaModel *model)
     {
        [weakSelf removeUid:uid];
        [weakSelf.delegate getUserInfoFinish];
        if (success)
        {
            success((LLUser *)model);
        }
    }
    failure:^(NSError *error)
    {
        [weakSelf removeUid:uid];
        if (fail) {
            fail(error);
        }
    }];
    
}

- (void)getUsersWithIds:(NSArray *)userIds {
    __weak typeof(self) weakSelf = self;
    NSString *uids = [userIds componentsJoinedByString:@","];
    
    [[LLHTTPRequestOperationManager shareManager] POSTListWithURL:Olla_API_Profiles parameters:@{@"uids":uids}
                                                        modelType:[LLUser class] success:^(NSArray *datas, BOOL hasNext)
     {
        [[LLAPICache sharedCache] setCacheArray:datas params:nil forURL:Olla_API_Profiles];
        for (LLUser *user in datas) {
            [userCache setObject:user forKey:user.uid];
        }
        if(weakSelf.delegate)[weakSelf.delegate getUserInfoFinish];
    }
   failure:^(NSError *error)
    {
        if ([weakSelf.delegate respondsToSelector:@selector(getUserInfoFail)]) {
            [weakSelf.delegate getUserInfoFail];
        }
    }];

}

- (LLUser *)userInfoWithUID:(NSString *)uid {
    if (uid.length == 0) {
        return nil;
    }
    if ([userCache objectForKey:uid]) {
        return [userCache objectForKey:uid];
    }
    LLUser *user = [LLUser find:uid];
    if (user) {
        [userCache setObject:user forKey:uid];
    }
    
    return user;
}

@end
