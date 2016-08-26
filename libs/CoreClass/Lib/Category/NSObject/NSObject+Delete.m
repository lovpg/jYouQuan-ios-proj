//
//  NSObject+Delete.m
//  BaseModel
//
//  Created by muxi on 15/3/30.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NSObject+Delete.h"
#import "NSObject+BaseModelCommon.h"
#import "LLFMDB.h"
#import "NSObject+Select.h"
#import "BaseModel.h"
#import "NSObject+MJProperty.h"
#import "MJProperty.h"
#import "BaseMoelConst.h"

@implementation NSObject (Delete)


/**
 *  条件删除
 *
 *  @param where   where
 *
 *  @return 执行结果
 */
+(BOOL)deleteWhere:(NSString *)where {

    if(![self checkTableExists]){
        [self createTable];
        return YES;
    }
    
    DDLogInfo(@"批量删除开始! %@ %@", self.modelName, where);
    
    NSArray *sqls = [self deleteSQLWhere:where];
    if (sqls.count == 0) {
        return YES;
    }
    BOOL res = [LLFMDB executeBatchUpdate:sqls];
    
    if (res) {
        DDLogInfo(@"批量删除成功! %@ %@", self.modelName, where);
    } else {
        DDLogInfo(@"批量删除失败! %@ %@", self.modelName, where);
    }
    
    return res;
}


/**
 *  根据hostId快速删除一条记录
 *
 *  @param hostId hostId
 *
 *  @return 执行结果
 */
+(BOOL)delete:(NSString *)hostId{
    
    NSString *where=[NSString stringWithFormat:@"hostId='%@'",hostId];
    
    return [self deleteWhere:where];
}

+(NSArray *)deleteSQLWhere:(NSString *)where {
    
    
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@",[self modelName]];
    
    if(where != nil) sql = [NSString stringWithFormat:@"%@ WHERE %@",sql,where];
    
    //添加结束的分号
    sql = [NSString stringWithFormat:@"%@;",sql];
    
    //删除之前需要把这些数据查询出来，获取对应的hostId，完成级联操作
    NSArray *deleteModels = [self selectWhere:where groupBy:nil orderBy:nil limit:nil];
    
    if(deleteModels==nil || deleteModels.count==0){//说明将要删除的数据为空，则可直接返回
        return nil;
    }

    NSMutableArray *sqls = [NSMutableArray array];
    [sqls addObject:sql];
    
    NSMutableDictionary *childrenDict = [NSMutableDictionary dictionary];
    
    //遍历模型对象
    
    [deleteModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BaseModel *baseModel = obj;
        [baseModel.class enumerateProperties:^(MJProperty *property, BOOL *stop) {
            //如果是过滤字段，直接跳过
            BOOL skip=[self skipField:property];
            
            if(!skip){
                
                NSString *sqliteTye = [self sqliteType:property.type.code];
                
                if([sqliteTye isEqualToString:EmptyString]){
                    NSString *modelName = property.type.code;
                    NSMutableArray *childrenArray = [childrenDict objectForKey:modelName];
                    
                    if (!childrenArray) {
                        childrenArray = [NSMutableArray array];
                        childrenDict[modelName] = childrenArray;
                    }
                    [childrenArray addObject:[NSString stringWithFormat:@"'%@'",baseModel.hostId]];
                }
            }
        }];
    }];
    
    if (childrenDict.count > 0) {
        [childrenDict.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *modelName = obj;
            Class modelClass = NSClassFromString(modelName);
            if (modelClass) {
                NSArray *pidArray = childrenDict[modelName];
                NSString *where = [NSString stringWithFormat:@"pModel='%@' AND pid in (%@)",NSStringFromClass(self.class),[pidArray componentsJoinedByString:@","]];
                NSArray *subSQLs = [modelClass deleteSQLWhere:where];
                [subSQLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *subSQL = obj;
                    if (![sqls containsObject:subSQL]) {
                        [sqls addObject:subSQL];
                    }
                }];
            }
        }];
    }
    
    return sqls;
}


@end
