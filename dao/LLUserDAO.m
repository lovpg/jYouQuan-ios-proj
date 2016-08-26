//
//  LLUserDAO.m
//  Olla
//
//  Created by null on 14-11-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLUserDAO.h"

@implementation LLUserDAO

- (void)get:(NSString *)uid
    success:(void (^)(LLUser *user))success
       fail:(void (^)(NSError *error))fail
{
    
    [[LLHTTPRequestOperationManager shareManager]
        GETWithURL:Olla_API_ProfileOther
        parameters:@{@"uid":uid}
        modelType:[LLUser class]
        success:^(OllaModel *model)
    {
        success((LLUser *)model);
    }
    failure:^(NSError *error)
    {
        fail(error);
    }];
}

- (void)me:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail{
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_ProfileMe parameters:nil modelType:[LLUser class] success:^(OllaModel *model) {
        success((LLUser *)model);
    } failure:^(NSError *error) {
        fail(error);
    }];
}






@end
