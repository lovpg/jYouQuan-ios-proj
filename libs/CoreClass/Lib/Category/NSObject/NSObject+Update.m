//
//  NSObject+Update.m
//  BaseModel
//
//  Created by muxi on 15/3/30.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NSObject+Update.h"
#import "NSObject+BaseModelCommon.h"
#import "NSObject+Select.h"
#import "BaseModel.h"
#import "NSObject+MJProperty.h"
#import "MJProperty.h"
#import "BaseMoelConst.h"
#import "LLFMDB.h"


@implementation NSObject (Update)

/**
 *  更新数据（级联更新）
 *
 *  @param model 模型数据
 *
 *  @return 执行结果
 */
+(BOOL)update:(id)model{
    
    //检查表是否存在，如果不存在，直接返回
    if(![self checkTableExists]){
        [self createTable];
        return NO;
    }
    
    if(![model isKindOfClass:[self class]]){
        DDLogInfo(@"错误：插入数据请使用%@模型类对象，您使用的是%@类型",[self modelName],[model class]);
        return NO;
    }
    
    BaseModel *baseModel=(BaseModel *)model;
    
    //查询此模型在数据库中是否存在，如果不存在，则无法更新
    id obj=[self find:baseModel.hostId];
    if(obj==nil) return NO;
    baseModel.updateTime = [[NSDate date] timeIntervalSince1970];
    
    //代码运行到这里，说明在数据库中的模型数据是存在的，执行更新操作
    NSMutableString *keyValueString = [NSMutableString string];
    
    //遍历成员属性
    [self enumerateProperties:^(MJProperty *property, BOOL *stop) {
        
        //如果是过滤字段，直接跳过
        BOOL skip=[self skipField:property];
        
        if(!skip){
            
            NSString *sqliteTye=[self sqliteType:property.type.code];
            
            id value =[model valueForKeyPath:property.name];
            
            if(![sqliteTye isEqualToString:EmptyString]){
                
                //拼接属性值
                //字符串需要再处理
                
                if([property.type.code isEqualToString:CoreNSString]){
                    //添加引号表明字符串
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLStringValue(value)];
                } else if([property.type.code isEqualToString:CoreNSNumber]){
                    //添加引号表明字符串
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLNumberValue(value)];
                } else if([property.type.code isEqualToString:CoreNSArray]){
                    //添加引号表明字符串
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLArrayValue(value)];
                }
                
                //拼接属性名及属性值
                [keyValueString appendFormat:@"%@=%@,",property.name,value];
                
            }else{
                
                //此属性是模型字段，级联更新
                if(property.name!=nil && value!=nil){
                    
                    BaseModel *childModel=(BaseModel *)value;
                    childModel.updateTime = [[NSDate date] timeIntervalSince1970];
                    //自动处理pModel:KVO
                    [childModel setValue:NSStringFromClass(baseModel.class) forKey:@"pModel"];
                    
                    //自动处理pid:KVO
                    [childModel setValue:baseModel.hostId forKey:@"pid"];
                    
                    //级联更新数据
                    BOOL childInsertRes = [NSClassFromString(property.type.code) update:childModel];
                    
                    if(!childInsertRes) DDLogInfo(@"错误：级联保存数据失败！级联父类：%@，子属性为：%@",NSStringFromClass(baseModel.class),value);
                }
            }
        }

    }];

    
    //删除最后的字符
    NSString *keyValues_sub=[self deleteLastChar:keyValueString];
    
    //得到最终的sql
    NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE hostId='%@';",[self modelName],keyValues_sub, baseModel.hostId];

    //执行更新
    BOOL updateRes = [LLFMDB executeUpdate:sql];
    
    if(!updateRes) DDLogInfo(@"错误：数据更新出错，出错模型数据为：%@",model);
    
    return updateRes;
}






/**
 *  更新数据（批量更新）
 *
 *  @param models 模型数组
 *
 *  @return 执行结果
 */
+(BOOL)updateModels:(NSArray *)models{
    
    if(models==nil || models.count==0) return NO;
    
    BOOL updateRes=YES;
    
    for (id obj in models) {
        
        BOOL res = [self update:obj];
        
        if(!res) updateRes=NO;
    }
    
    return updateRes;
}


+(NSArray *)updateSQLWithModel:(id)model {
    
    //检查表是否存在，如果不存在，直接返回
    if(![self checkTableExists]){
        [self createTable];
        return nil;
    }
    
    BaseModel *baseModel=(BaseModel *)model;
    baseModel.updateTime = [[NSDate date] timeIntervalSince1970];
    
    //代码运行到这里，说明在数据库中的模型数据是存在的，执行更新操作
    NSMutableString *keyValueString=[NSMutableString string];
    
    NSMutableArray *sqls = [NSMutableArray array];
    
    //遍历成员属性
    [self enumerateProperties:^(MJProperty *property, BOOL *stop) {
        
        //如果是过滤字段，直接跳过
        BOOL skip=[self skipField:property];
        
        if(!skip){
            
            NSString *sqliteTye=[self sqliteType:property.type.code];
            
            id value =[model valueForKeyPath:property.name];
            
            if(![sqliteTye isEqualToString:EmptyString]){
                
                //拼接属性值
                //字符串需要再处理
                
                if([property.type.code isEqualToString:CoreNSString]){
                    //添加引号表明字符串
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLStringValue(value)];
                } else if([property.type.code isEqualToString:CoreNSNumber]){
                    //添加引号表明字符串
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLNumberValue(value)];
                } else if([property.type.code isEqualToString:CoreNSArray]){
                    //添加引号表明字符串
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLArrayValue(value)];
                }
                
                //拼接属性名及属性值
                [keyValueString appendFormat:@"%@=%@,",property.name,value];
                
            }else{
                
                //此属性是模型字段，级联更新
                if(property.name!=nil && value!=nil){
                    
                    BaseModel *childModel=(BaseModel *)value;
                    
                    //自动处理pModel:KVO
                    [childModel setValue:NSStringFromClass(baseModel.class) forKey:@"pModel"];
                    
                    //自动处理pid:KVO
                    [childModel setValue:baseModel.hostId forKey:@"pid"];
                    
                    NSArray *subSQLs = [[childModel class] updateSQLWithModel:childModel];
                    [subSQLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *subSQL = obj;
                        if (![sqls containsObject:subSQL]) {
                            [sqls addObject:subSQL];
                        }
                    }];
                }
            }
        }
        
    }];
    
    
    //删除最后的字符
    NSString *keyValues_sub=[self deleteLastChar:keyValueString];
    
    //得到最终的sql
    NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE hostId='%@';",[self modelName],keyValues_sub, baseModel.hostId];
    
    [sqls insertObject:sql atIndex:0];
    return sqls;
}

+(NSArray *)updateSQLWithModels:(NSArray *)models {
    NSMutableArray *sqls = [NSMutableArray array];
    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *subSQLs = [self updateSQLWithModel:obj];
        [subSQLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *subSQL = obj;
            if (![sqls containsObject:subSQL]) {
                [sqls addObject:subSQL];
            }
        }];
    }];
    return sqls;
}



@end
