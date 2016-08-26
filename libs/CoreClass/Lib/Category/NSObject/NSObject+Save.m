//
//  NSObject+Save.m
//  BaseModel
//
//  Created by muxi on 15/3/30.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NSObject+Save.h"
#import "BaseModel.h"
#import "NSObject+Select.h"
#import "NSObject+BaseModelCommon.h"
#import "NSObject+Insert.h"
#import "NSObject+Update.h"

@implementation NSObject (Save)

/**
 *  保存数据（单个）
 *
 *  @param model 模型数据
 *
 *  @return 执行结果
 */
+(BOOL)save:(id)model{
    
    if(![self checkTableExists]){
        [self createTable];
    }
    
    if(![model isKindOfClass:[self class]]){
        NSLog(@"错误：插入数据请使用%@模型类对象，您使用的是%@类型",[self modelName],[model class]);
        return NO;
    }
    
    
    BaseModel *baseModel = (BaseModel *)model;
    BaseModel *dbModel = [self find:baseModel.hostId];
    
    BOOL saveRes = NO;
    
    if(dbModel==nil){//要保存的数据不存在，执行添加操作
        NSLog(@"现在是新增");
        dbModel.updateTime = [[NSDate date] timeIntervalSince1970];
        NSArray *sql = [self insertSQLWithModel:baseModel];
        saveRes = [LLFMDB executeBatchUpdate:sql];
        
    } else {//要保存的数据存在，执行更新操作
        NSLog(@"现在是更新");
        baseModel.updateTime = [[NSDate date] timeIntervalSince1970];
        NSArray *sql = [self updateSQLWithModel:baseModel];
        saveRes = [LLFMDB executeBatchUpdate:sql];
    }
    
    return saveRes;
}



/**
 *  保存数据（数组）
 *
 *  @param models 模型数组
 *
 *  @return 执行结果
 */
+(BOOL)saveModels:(NSArray *)models{
    DDLogInfo(@"批量保存开始! %@", self.modelName);
    if(![self checkTableExists]){
        [self createTable];
    }
    
    if(models==nil || models.count==0) return NO;
    
    double updateTime = [[NSDate date] timeIntervalSince1970];
    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BaseModel *baseModel = obj;
        baseModel.updateTime = updateTime;
    }];
    
    NSMutableArray *sqls = [NSMutableArray array];
    
    NSMutableArray *hostIds = [NSMutableArray array];
    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BaseModel *model = (BaseModel *)obj;
        NSString *hostId = model.hostId;
        if (hostId && ![hostIds containsObject:hostId]) {
            [hostIds addObject:hostId];
        }
    }];
    
    // 这里要忽略级联对象
    BaseModel *model = models.firstObject;
    NSString *where = [NSString stringWithFormat:@"ollaURL = '%@' AND pModel = '' AND pid = ''", model.ollaURL];
    NSArray *existHostIds = [self findhostIds:hostIds where:where];

    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BaseModel *model = (BaseModel *)obj;
        NSArray *subSQLs = nil;
        if ([existHostIds containsObject:model.hostId]) {
            subSQLs = [self updateSQLWithModel:model];
        } else {
            subSQLs = [self insertSQLWithModel:model];
        }
        
        [subSQLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *subSQL = obj;
            if (![sqls containsObject:subSQL]) {
                [sqls addObject:subSQL];
            }
        }];
    }];
    
    if (sqls.count == 0) {
        return NO;
    }
    
    BOOL saveRes = [LLFMDB executeBatchUpdate:sqls];
    
    if (saveRes) {
        DDLogInfo(@"批量保存结束! %@", self.modelName);
    }
    
    return saveRes;
}




/**
 *  保存数据：自动判断是单个还是数组
 *
 *  @param obj 数据
 *
 *  @return 执行结果
 */
+(BOOL)saveDirect:(id)obj{
    
    return [obj isKindOfClass:[NSArray class]]?[self saveModels:obj]:[self save:obj];
}


@end
