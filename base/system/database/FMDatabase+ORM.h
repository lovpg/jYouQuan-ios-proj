//
//  FMDatabase+ORM.h
//  OllaFramework
//
//  Created by nonstriater on 14-8-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//


@interface FMDatabase (ORM)


- (BOOL)createTableWithName:(NSString *)name modelType:(Class)clazz;
- (BOOL)insertItemInTable:(NSString *)name model:(NSObject *)model;
- (BOOL)updateItemInTable:(NSString *)name model:(NSObject *)model;
- (BOOL)deleteItemInTable:(NSString *)name withKeyID:(NSString *)key;


//全部顺序查询
- (NSArray *)queryItemsInTable:(NSString *)name usingModelType:(Class)clazz;
//分页顺序查询
- (NSArray *)queryItemsInTable:(NSString *)name usingModelType:(Class)clazz start:(NSInteger)start size:(NSInteger)size;
//全部倒叙查询
- (NSArray *)queryItemsReversingInTable:(NSString *)name usingModelType:(Class)clazz;
//分页倒叙查询
- (NSArray *)queryItemsReversingInTable:(NSString *)name usingModelType:(Class)clazz start:(NSInteger)start size:(NSInteger)size;


- (BOOL)isTableExists:(NSString *)tableName;
- (NSInteger)countInTable:(NSString *)name;

@end


/**
 还有一种写法是：
 定义一个Object基类（如OllaModel）让Model类继承，在OllaModel里实现增删查改的操作
 */


