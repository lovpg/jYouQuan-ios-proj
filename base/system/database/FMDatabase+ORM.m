//
//  FMDatabase+ORM.m
//  OllaFramework
//
//  Created by nonstriater on 14-8-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "FMDatabase+ORM.h"

@implementation FMDatabase (ORM)

/**
model的属性(常见的)有：
 string
 int
 long
 double
 枚举enum
 uiimage
 nsdata
 nsarray
 nsdictionary
 nsdate
 
 sqlite支持的类型：
 text
 integer
 real
 blob

 */
- (BOOL)createTableWithName:(NSString *)name modelType:(Class)clazz{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS %@ ()";
    [self executeUpdate:sql];
    if ([self hadError]) {
        return NO;
    }
    return YES;
}
- (BOOL)insertItemInTable:(NSString *)name model:(NSObject *)model{
return NO;
}
- (BOOL)updateItemInTable:(NSString *)name model:(NSObject *)model{

return NO;}
- (BOOL)deleteItemInTable:(NSString *)name withKeyID:(NSString *)key{

return NO;}


//全部顺序查询
- (NSArray *)queryItemsInTable:(NSString *)name usingModelType:(Class)clazz{
    return nil;
}
//分页顺序查询
- (NSArray *)queryItemsInTable:(NSString *)name usingModelType:(Class)clazz start:(NSInteger)start size:(NSInteger)size{

return nil;}
//全部倒叙查询
- (NSArray *)queryItemsReversingInTable:(NSString *)name usingModelType:(Class)clazz{
return nil;
}
//分页倒叙查询
- (NSArray *)queryItemsReversingInTable:(NSString *)name usingModelType:(Class)clazz start:(NSInteger)start size:(NSInteger)size{

return nil;}


- (BOOL)isTableExists:(NSString *)tableName{
    return NO;
}
- (NSInteger)countInTable:(NSString *)name{
    return 0;
}


@end
