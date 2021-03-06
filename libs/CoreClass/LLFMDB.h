//
//  LLFMDB.h
//  Olla
//
//  Created by Pat on 15/8/11.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface LLFMDB : NSObject

AS_SINGLETON(LLFMDB, sharedDB);

// 设置数据库 id
//
+(void)setIdentifier:(NSString *)identifier;

/**
 *  执行一个更新语句
 *
 *  @param sql 更新语句的sql
 *
 *  @return 更新语句的执行结果
 */
+(BOOL)executeUpdate:(NSString *)sql;

+(BOOL)executeBatchUpdate:(NSArray *)sqls;


/**
 *  执行一个查询语句
 *
 *  @param sql              查询语句sql
 *  @param queryResBlock    查询语句的执行结果
 */
+(void)executeQuery:(NSString *)sql queryResBlock:(void(^)(FMResultSet *set))queryResBlock;


/**
 *  查询出指定表的列
 *
 *  @param table table
 *
 *  @return 查询出指定表的列的执行结果
 */
+(NSArray *)executeQueryColumnsInTable:(NSString *)table;

/**
 *  表记录数计算
 *
 *  @param table 表
 *
 *  @return 记录数
 */
+(NSUInteger)countTable:(NSString *)table;

+(void)close;

@end
