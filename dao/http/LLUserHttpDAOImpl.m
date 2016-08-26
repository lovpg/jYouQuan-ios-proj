//
//  LLUserHttpDAOImpl.m
//  Olla
//
//  Created by nonstriater on 14-8-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLUserHttpDAOImpl.h"

@implementation LLUserHttpDAOImpl


//使用网络同步操作,使用gcd信号量来实现同步
//获取不到用户资料消息会丢掉，这里可能会造成message丢失！！
- (LLUser *)getUser:(NSString *)uid{
    
    __block LLUser *user = nil;
    // 使用包装的GETWithURL，就不是同步操作了？
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[LLHTTPRequestOperationManager shareManager] GET:Olla_API_ProfileOther parameters:@{@"uid":uid} success:^(AFHTTPRequestOperation *operation,id responsObject){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responsObject options:NSJSONReadingMutableLeaves error:nil];
        if (![dict isDictionary] ) {
            DDLogError(@"get user info not dict %@",dict);
            return ;
        }
        if (![dict[@"status"] isEqualToString:@"200"]) {
            DDLogError(@"get user info error %@",dict);
            return ;
        }
        
        if (![dict[@"data"] isDictionary]) {
            DDLogError(@"get user info not dict %@",dict);
            return ;
        }
        user = [dict[@"data"] modelFromDictionaryWithClassName:[LLUser class]];
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        DDLogError(@"get user info from net fail：%@",error);
        dispatch_semaphore_signal(semaphore);
    }];
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//阻塞线程，直到信号量大于0
    
    return user;
}


@end




