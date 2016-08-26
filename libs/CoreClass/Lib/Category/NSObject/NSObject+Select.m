    //
//  NSObject+Select.m
//  BaseModel
//
//  Created by muxi on 15/3/30.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NSObject+Select.h"
#import "LLFMDB.h"
#import "MJProperty.h"
#import "BaseModel.h"
#import "NSObject+BaseModelCommon.h"
#import "BaseMoelConst.h"

@implementation NSObject (Select)


/**
 *  查询（无需包含关键字）
 *
 *  @param where   where
 *  @param groupBy groupBy
 *  @param orderBy orderBy
 *  @param limit   limit
 *
 *  @return 结果集
 */
+(NSArray *)selectWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit{
    
    if(![self checkTableExists]) {
        [self createTable];
        return nil;
    }
    
//    DDLogInfo(@"查询开始: %@ %@", self.modelName, where);

    NSString *sql = [self selectSQLWhere:where groupBy:groupBy orderBy:orderBy limit:limit];

    NSMutableArray *resultsArray = [NSMutableArray array];
    NSMutableArray *fieldsArray = [NSMutableArray array];
    NSMutableArray *hostIdArray = [NSMutableArray array];
    
//    DDLogInfo(@"查询sql:%@",sql);
    
    [LLFMDB executeQuery:sql queryResBlock:^(FMResultSet *set) {
        
        while ([set next]) {
            
            BaseModel *model = [[self alloc] init];
            
            [self enumerateProperties:^(MJProperty *property, BOOL *stop) {
                
                BOOL skip=[self skipField:property];
                
                if(!skip){
                    
                    NSString *code = property.type.code;
                    
                    NSString *sqliteTye=[self sqliteType:code];
                    
                    if(![sqliteTye isEqualToString:EmptyString]){
                        
                        NSString *propertyName = property.name;
                        NSString *value=[set stringForColumn:propertyName];
                        if([CoreBOOL rangeOfString:code].length>0){//bool
                            
                            NSNumber *boolValue = @(value.integerValue);
                            
                            //设置值
                            [model setValue:boolValue forKey:propertyName];
                            
                        } else if([CoreNSArray rangeOfString:code].length>0) {
                            // 数组
                            id arrayValue = [value jsonValue];
                            if ([arrayValue isKindOfClass:[NSArray class]]) {
                                [model setValue:arrayValue forKey:propertyName];
                            }
                        } else{
                            //设置值
                            [model setValue:value forKey:propertyName];
                        }
                        
                    } else {
                        if(![fieldsArray containsObject:property]) [fieldsArray addObject:property];
                    }
                }
            }];

            [hostIdArray addObject:[NSString stringWithFormat:@"'%@'",model.hostId]];
            [resultsArray addObject:model];
        }
    }];
    
    if(resultsArray.count > 0 && fieldsArray.count > 0){
        NSMutableDictionary *childrenDict = [NSMutableDictionary dictionary];
        
        [fieldsArray enumerateObjectsUsingBlock:^(MJProperty *ivar, NSUInteger idx, BOOL *stop) {
            NSString *clazzName = ivar.type.code;
            Class childClazz = NSClassFromString(clazzName);
            if (childClazz) {
                NSString *childWhere = [NSString stringWithFormat:@"pModel='%@' AND pid in (%@)", NSStringFromClass(self.class), [hostIdArray componentsJoinedByString:@","]];
                
                NSArray *children = [childClazz selectWhere:childWhere groupBy:nil orderBy:nil limit:nil];
                NSMutableDictionary *covertDict = [NSMutableDictionary dictionary];
                [children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    BaseModel *childModel = obj;
                    [covertDict setObject:childModel forKey:childModel.pid];
                }];
                [childrenDict setObject:covertDict forKey:clazzName];
            }
        }];
        
        if (childrenDict.count > 0) {
            [resultsArray enumerateObjectsUsingBlock:^(BaseModel *model, NSUInteger idx, BOOL *stop) {
                [fieldsArray enumerateObjectsUsingBlock:^(MJProperty *ivar, NSUInteger idx, BOOL *stop) {
                    NSString *clazzName = ivar.type.code;
                    if (NSClassFromString(clazzName)) {
                        NSDictionary *childDict = childrenDict[clazzName];
                        BaseModel *childModel = childDict[model.hostId];
                        [model setValue:childModel forKey:ivar.name];
                    }
                    
                }];
            }];
        }
    }
//    DDLogInfo(@"查询结束: %@ %@", self.modelName, where);
    return resultsArray;
}

+ (NSString *)selectSQLWhere:(NSString *)where groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit {
    NSMutableString *sqlM=[NSMutableString stringWithFormat:@"SELECT * FROM %@",[self modelName]];
    //where
    if(where != nil) [sqlM appendFormat:@" WHERE %@",where];
    
    //groupBy
    if(groupBy != nil) [sqlM appendFormat:@" GROUP BY %@",groupBy];
    
    //orderBy
    if(orderBy != nil) [sqlM appendFormat:@" ORDER BY %@",orderBy];
    
    //limit
    if(limit != nil) [sqlM appendFormat:@" LIMIT %@",limit];
    
    //结束添加分号
    NSString *sql=[NSString stringWithFormat:@"%@;",sqlM];
    return sql;
}


/**
 *  根据hostId精准的查找唯一对象
 */
+(instancetype)find:(NSString *)hostId{
    
    if(![self checkTableExists]){
        [self createTable];
        return nil;
    }
    
    NSString *where=[NSString stringWithFormat:@"hostId='%@'",hostId];
    
    NSString *limit = @"1";
    
    NSArray *models = [self selectWhere:where groupBy:nil orderBy:nil limit:limit];
    
    if(models==nil || models.count==0) return nil;
    
    return models.firstObject;
}


+(NSArray *)findhostIds:(NSArray *)hostIds where:(NSString *)where {
    // 此处返回的是 hostIds 数组, 不是对象

    if(![self checkTableExists]){
        [self createTable];
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    [hostIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:[NSString stringWithFormat:@"'%@'", obj]];
    }];
    
    NSString *string = [array componentsJoinedByString:@","];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@",[self modelName]];
    [sql appendFormat:@" WHERE hostId in (%@)", string] ;
    if (where) {
        [sql appendFormat:@" AND %@", where];
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    [LLFMDB executeQuery:sql queryResBlock:^(FMResultSet *set) {
        while ([set next]) {
            NSString *hostId = [set stringForColumn:@"hostId"];
            if (hostId) {
                [resultArray addObject:hostId];
            }
        }
    }];
    
    return resultArray;
}



@end
