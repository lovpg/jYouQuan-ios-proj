//
//  LLFMDB.m
//  Olla
//
//  Created by Pat on 15/8/11.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLFMDB.h"

#define OLLA_DATABASE_VERSION @"6"

@interface LLFMDB ()

@property (nonatomic,strong) NSString *identifier;
@property (nonatomic,strong) FMDatabaseQueue *queue;

@end

@implementation LLFMDB

DEF_SINGLETON(LLFMDB, sharedDB);

+ (void)load {
    
}

+ (void)setIdentifier:(NSString *)identifier {
    if (identifier.length == 0) {
        return;
    }
    
    if ([[LLFMDB sharedDB].identifier isEqualToString:identifier]) {
        return;
    }
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *ollaDBPath = [documentPath stringByAppendingPathComponent:@"OllaDB"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:ollaDBPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ollaDBPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *databasePath = nil;
    
    if ([LLAppHelper isTestEnv]) {
        databasePath = [ollaDBPath stringByAppendingFormat:@"/%@_V%@_test_env.db",identifier, OLLA_DATABASE_VERSION];
    } else {
        databasePath = [ollaDBPath stringByAppendingFormat:@"/%@_V%@.db",identifier, OLLA_DATABASE_VERSION];
        
        // 删除老数据库
        int version = OLLA_DATABASE_VERSION.intValue - 1;
        
        for (int i=version; i>0; i--) {
            NSString *oldDatabasePath = [ollaDBPath stringByAppendingFormat:@"/%@_V%i.db", identifier, i];
            if ([[NSFileManager defaultManager] fileExistsAtPath:oldDatabasePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:oldDatabasePath error:nil];
            }
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        // 检测数据库是否损坏
        BOOL corrupted = NO;
        
        FMDatabase *checkDB = [FMDatabase databaseWithPath:databasePath];
        if ([checkDB open]) {
            FMResultSet *set = [checkDB executeQuery:@"PRAGMA integrity_check"];
            if ([set next]) {
                NSString *status = [set objectForColumnIndex:0];
                if (![status isEqualToString:@"ok"]) {
                    corrupted = YES;
                }
            } else {
                corrupted = YES;
            }
        }
        
        [checkDB close];
        
        if (corrupted) {
            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
        }
    }
    
    LLFMDB *db = [LLFMDB sharedDB];
    if (db.queue) {
        [db.queue close];
        db.queue = nil;
    }
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    db.queue = queue;
    db.identifier = identifier;
}

+(void)close {
    LLFMDB *db = [LLFMDB sharedDB];
    db.identifier = nil;
    [db.queue close];
    db.queue = nil;
}

/**
 *  执行一个更新语句
 *
 *  @param sql 更新语句的sql
 *
 *  @return 更新语句的执行结果
 */
+(BOOL)executeUpdate:(NSString *)sql{
    
    __block BOOL updateRes = NO;
    
    LLFMDB *db = [LLFMDB sharedDB];
    
    if (!db.queue) {
        return updateRes;
    }
    
    [db.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        updateRes = [db executeUpdate:sql];
        [db commit];
    }];
    
    if (!updateRes) {
        DDLogError(@"数据库操作失败,SQL:%@", sql);
    }
    
    return updateRes;
}

+(BOOL)executeBatchUpdate:(NSArray *)sqls {
    
    __block BOOL updateRes = NO;

    LLFMDB *db = [LLFMDB sharedDB];
    
    if (!db.queue) {
        return updateRes;
    }
    
    [db.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        [sqls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *sql = (NSString *)obj;
            updateRes = [db executeUpdate:sql];
            if (!updateRes) {
                DDLogError(@"数据库操作失败,SQL:%@", sql);
                *stop = YES;
            }
        }];
        
        if (updateRes) {
            [db commit];
        } else {
            [db rollback];
        }
        
        
    }];
    
    return updateRes;
}


/**
 *  执行一个查询语句
 *
 *  @param sql              查询语句sql
 *  @param queryResBlock    查询语句的执行结果
 */
+(void)executeQuery:(NSString *)sql queryResBlock:(void(^)(FMResultSet *set))queryResBlock{
    
    LLFMDB *db = [LLFMDB sharedDB];
    
    if (!db.queue) {
        queryResBlock(nil);
    }
    
    [db.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        if(queryResBlock != nil) queryResBlock(set);
    }];
}


/**
 *  查询出指定表的列
 *
 *  @param table table
 *
 *  @return 查询出指定表的列的执行结果
 */
+(NSArray *)executeQueryColumnsInTable:(NSString *)table{
    
    NSMutableArray *columnsM=[NSMutableArray array];
    
    NSString *sql=[NSString stringWithFormat:@"PRAGMA table_info (%@);",table];
    
    [self executeQuery:sql queryResBlock:^(FMResultSet *set) {
        
        //循环取出数据
        while ([set next]) {
            NSString *column = [set stringForColumn:@"name"];
            [columnsM addObject:column];
        }
        
        if(columnsM.count==0) DDLogError(@"code=2：您指定的表：%@,没有字段信息，可能是表尚未创建！",table);
    }];
    
    return [columnsM copy];
}


/**
 *  表记录数计算
 *
 *  @param table 表
 *
 *  @return 记录数
 */
+(NSUInteger)countTable:(NSString *)table{
    
    NSString *alias=@"count";
    
    NSString *sql=[NSString stringWithFormat:@"SELECT COUNT(*) AS %@ FROM %@;",alias,table];
    
    __block NSUInteger count=0;
    
    [self executeQuery:sql queryResBlock:^(FMResultSet *set) {
        
        while ([set next]) {
            
            count = [[set stringForColumn:alias] integerValue];
        }
    }];
    
    return count;
}

@end
