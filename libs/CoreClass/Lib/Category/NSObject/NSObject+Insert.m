//
//  NSObject+Insert.m
//  BaseModel
//
//  Created by muxi on 15/3/30.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NSObject+Insert.h"
#import "BaseModel.h"
#import "MJProperty.h"
#import "NSObject+BaseModelCommon.h"
#import "BaseMoelConst.h"
#import "LLFMDB.h"
#import "NSObject+Select.h"


@implementation NSObject (Insert)

/**
 *  插入数据（单个）
 *
 *  @param model 模型数据
 *
 *  @return 插入数据的执行结果
 */
+(BOOL)insert:(id)model{
    
    if(![self checkTableExists]){
        [self createTable];
    }

    if(![model isKindOfClass:[self class]]){
        DDLogInfo(@"错误：插入数据请使用%@模型类对象，您使用的是%@类型",[self modelName],[model class]);
        return NO;
    }
    
    BaseModel *baseModel=(BaseModel *)model;

    //无hostId的数据插入都是耍流氓
    if(baseModel.hostId.length == 0){
        DDLogInfo(@"错误：数据插入失败，你必须设置模型的模型hostId!");
        return NO;
    }
    DDLogInfo(@"数据插入开始%@",[NSThread currentThread]); 
    BaseModel *dbModel=[self find:baseModel.hostId];
    
    if(dbModel!=nil){
        DDLogInfo(@"%@的数据已经存在", baseModel.hostId);
        return NO;
    }
    
    NSMutableString *fields=[NSMutableString string];
    NSMutableString *values=[NSMutableString string];

    //遍历成员属性
    [self enumerateProperties:^(MJProperty *property, BOOL *stop) {
        
        //如果是过滤字段，直接跳过
        BOOL skip=[self skipField:property];
        
        if(!skip){
            
            NSString *sqliteTye=[self sqliteType:property.type.code];
            
            id value =[model valueForKeyPath:property.name];
            
            if(![sqliteTye isEqualToString:EmptyString]){
                
                //拼接属性名
                [fields appendFormat:@"%@,",property.name];
                
                //拼接属性值
                //字符串需要再处理
                
                if([property.type.code isEqualToString:CoreNSString]){
                    //添加引号表明字符串
                    value=[NSString stringWithFormat:@"'%@'",LLCovertSQLStringValue(value)];
                } else if([property.type.code isEqualToString:CoreNSNumber]){
                    value=[NSString stringWithFormat:@"%@",LLCovertSQLNumberValue(value)];
                } else if([property.type.code isEqualToString:CoreNSArray]){
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLArrayValue(value)];
                }
                [values appendFormat:@"%@,",value];
                
            } else {
                //此属性是模型，且已经动态生成模型字段对应的数据表
                if(property.name!=nil && value!=nil && [value isKindOfClass:[BaseModel class]]){
                    
                    BaseModel *childModel=(BaseModel *)value;
                    
                    //级联对象
                    childModel.pModel = NSStringFromClass(baseModel.class);
                    childModel.pid = baseModel.hostId;
                    childModel.ollaURL = baseModel.ollaURL;
                    //级联保存数据
                    BOOL childInsertRes = [NSClassFromString(property.type.code) insert:value];
                    
                    if(!childInsertRes)  {
                        DDLogInfo(@"错误：级联保存数据失败！级联父类：%@，子属性为：%@",NSStringFromClass(baseModel.class),value);
                    }
                }
            }
        }
    }];


    //删除最后的字符
    NSString *fields_sub=[self deleteLastChar:fields];
    NSString *values_sub=[self deleteLastChar:values];

    //得到最终的sql
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);",[self modelName],fields_sub,values_sub];
    
    //执行添加
    BOOL insertRes = [LLFMDB executeUpdate:sql];
    
    if(!insertRes) DDLogInfo(@"错误：添加对象失败%@",baseModel);
    DDLogInfo(@"数据插入结束%@",[NSThread currentThread]);
    return insertRes;
}




/**
 *  插入数据（批量）
 *
 *  @param models 模型数组
 *
 *  @return 批量插入数据的执行结果
 */
+(BOOL)inserts:(NSArray *)models{
    
    if(![self checkTableExists]){
        [self createTable];
    }
    
    BOOL insertsRes=YES;
    DDLogInfo(@"批量插入开始%@",[NSThread currentThread]);
    for (BaseModel *baseModel in models) {
        
        BOOL insertRes = [self insert:baseModel];
        
        //如果有一个出错，则认为整个数据批量插入失败
        if(!insertRes) insertsRes=NO;
    }
    DDLogInfo(@"批量插入结束%@",[NSThread currentThread]);
    return insertsRes;
}


+(NSArray *)insertSQLWithModel:(id)model {
    
    BaseModel *baseModel=(BaseModel *)model;
    
    NSMutableString *fields = [NSMutableString string];
    NSMutableString *values = [NSMutableString string];
    NSMutableArray *sqls = [NSMutableArray array];
    
    //遍历成员属性
    [self enumerateProperties:^(MJProperty *property, BOOL *stop) {
        
        //如果是过滤字段，直接跳过
        BOOL skip=[self skipField:property];
        
        if(!skip){
            
            NSString *sqliteTye=[self sqliteType:property.type.code];
            
            id value =[model valueForKeyPath:property.name];
            
            if(![sqliteTye isEqualToString:EmptyString]){
                
                //拼接属性名
                [fields appendFormat:@"%@,",property.name];
                
                //拼接属性值
                //字符串需要再处理
                
                if([property.type.code isEqualToString:CoreNSString]){
                    //添加引号表明字符串
                    value=[NSString stringWithFormat:@"'%@'",LLCovertSQLStringValue(value)];
                } else if([property.type.code isEqualToString:CoreNSNumber]){
                    value=[NSString stringWithFormat:@"%@",LLCovertSQLNumberValue(value)];
                } else if([property.type.code isEqualToString:CoreNSArray]){
                    value = [NSString stringWithFormat:@"'%@'",LLCovertSQLArrayValue(value)];
                }
                [values appendFormat:@"%@,",value];
                
            } else {
                //此属性是模型，且已经动态生成模型字段对应的数据表
                if(property.name!=nil && value!=nil && [value isKindOfClass:[BaseModel class]]){
                    
                    BaseModel *childModel=(BaseModel *)value;
                    // 检测级联对象表是否存在
                    if (![[childModel class] checkTableExists]) {
                        [[childModel class] createTable];
                    }
                    // 级联对象
                    childModel.pModel = NSStringFromClass(baseModel.class);
                    childModel.pid = baseModel.hostId;
                    childModel.ollaURL = baseModel.ollaURL;
                    
                    NSArray *subSQLs = [[childModel class] insertSQLWithModel:childModel];
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
    NSString *fields_sub = [self deleteLastChar:fields];
    NSString *values_sub = [self deleteLastChar:values];
    
    //得到最终的sql
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);",[self modelName],fields_sub,values_sub];
    [sqls insertObject:sql atIndex:0];
    return sqls;
}

@end
