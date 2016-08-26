//
//  LLUserDataSource.h
//  Olla
//
//  Created by nonstriater on 14-8-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLUser.h"
#import "LLUserDAO.h"

#import "LLUserSqliteDAOImpl.h"
#import "LLUserHttpDAOImpl.h"

/**
 查找用户信息,在本地查找，找不到就去网络取
 依赖 LLFriendsDataSource,LLChatsDataSource
 */

//DataSource还不是真正意义上的DAO，这是为UI服务的一个数据源
@interface LLUserDataSource : NSObject

@property(nonatomic,strong) LLUserSqliteDAOImpl *sqlUser;
@property(nonatomic,strong) LLUserHttpDAOImpl *httpUser;

- (LLUser *)getUser:(NSString *)uid;


@end


