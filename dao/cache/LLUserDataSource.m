//
//  LLUserDataSource.m
//  Olla
//
//  Created by nonstriater on 14-8-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLUserDataSource.h"
#import "LLUser.h"


@implementation LLUserDataSource

// 使用依赖注入技术
- (id)init{
    self =[super init];
    if (!self) {
        return nil;
    }

    _httpUser = [[LLUserHttpDAOImpl alloc] init];
    
    return self;
}

// 内存：chats内存，friends内存，
// 数据库：chats表，friends表

- (LLUser *)getUser:(NSString *)uid{
    
    LLUser *user = [_sqlUser getUser:uid];//使用同步操作
    if (!user) {
        user = [_httpUser getUser:uid];
    }
    
    return user;
}

@end


