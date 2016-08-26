//
//  BaseModel.m
//  4s
//
//  Created by muxi on 15/3/11.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "BaseModel.h"
#import "NSObject+MJProperty.h"
#import "MJProperty.h"
#import "BaseMoelConst.h"
#import "LLFMDB.h"
#import "NSObject+Create.h"
#import "NSObject+MJKeyValue.h"
#import "NSObject+Select.h"
#import "NSDictionary+Sqlite.h"
#import "CoreArchive.h"
#import "NSObject+Contrast.h"
#import "NSObject+Save.h"
#import "NSObject+BaseModelCommon.h"

@implementation BaseModel


+(void)initialize{
    
    //自动创表
    [self createTable];
}

-(NSString *)hostId {
    return [self uniqueId];
}

-(NSString *)uniqueId {
    return _hostId;
}


+(NSDictionary *)replacedKeyFromPropertyName{
    return @{@"hostId":@"id"};
}


/** 不做本地缓存的网络请求GET/POST成功统一处理 */
+(void)hostWithouSqliteRequestHandleData:(id)obj userInfo:(NSDictionary *)userInfo successBlock:(void(^)(id modelData,BaseModelDataSourceType sourceType,NSDictionary *userInfo))successBlock errorBlock:(void(^)(NSString *errorResult,NSDictionary *userInfo))errorBlock{
    
    //错误数据解析
    NSString *errorResult = [self baseModel_parseErrorData:obj];
    
    if(errorResult != nil){ if(errorBlock != nil) errorBlock(errorResult,userInfo); return;}
    
    //服务器返回数据GET/POST统一处理(已经经过所有错误处理)
    id modelData = [self hostDataHandle:obj];
    
    //成功回调
    if(successBlock !=nil ) successBlock(modelData,BaseModelDataSourceHostType_Sqlite_Nil,userInfo);
}




/** 网络数据和服务器数据对比 */
+(BOOL)contrastWithHostModelData:(id)hostModelData sqliteModelData:(id)sqliteModelData{
   
    BOOL isTheSame = NO;
    
    //这个数据是从结果集出来的，是一个数组
    NSArray *sqliteModelDataArray = (NSArray *)sqliteModelData;
    
    //数据类型
    BaseModelHostDataType dataType = [self baseModel_hostDataType];
    
    //两个都有值才进行对比，否则为不一样
    if(hostModelData != nil && (sqliteModelDataArray.count !=0)){
        
        if(BaseModelHostDataTypeModelSingle == dataType){//模型：单个
            
            //取出数据库模型对象
            BaseModel *sqliteModelSing = sqliteModelDataArray.firstObject;
            
            isTheSame = [self contrastModel1:hostModelData model2:sqliteModelSing];
            
        }else if (BaseModelHostDataTypeModelArray == dataType){//模型：数组
            
            isTheSame = [self contrastModels1:hostModelData models2:sqliteModelDataArray];
        }
    }
    
    if(isTheSame){
        NSLog(@"相同");
    }else{
        NSLog(@"不同");
    }
    
    return isTheSame;
}






/** 服务器返回数据GET/POST统一处理(已经经过所有错误处理) */
+(id)hostDataHandle:(id)obj{
    
    //字典转模型数据
    //使用id是因为可能是单个模型，也可能是模型数组
    id modelData = nil;
    
    //数组解析
    //userfullHostData：是真正本模型需要的数据体，还没有经历字典转模型
    id userfullHostData = [self baseModel_findUsefullData:obj];
    
    //数据类型
    BaseModelHostDataType dataType = [self baseModel_hostDataType];
    
    if(BaseModelHostDataTypeModelSingle == dataType){//模型：单个
        
        //字典转模型：泛型
        BaseModel *baseModel = [self objectWithKeyValues:userfullHostData];
        
        //得到模型：单个
        modelData = @[baseModel];
        
    }else if (BaseModelHostDataTypeModelArray == dataType){//模型：数组
        
        //字典转模型：泛型
        NSArray *baseModelArray = [self objectArrayWithKeyValuesArray:userfullHostData];
        
        //得到模型：数组
        modelData = baseModelArray;
    }
    
    return modelData;
}





/** 模型对比时需要忽略的字段 */
+(NSArray *)constrastIgnorFields{
    return @[@"pModel",@"pid"];
}


/*
 *  协议方法区
 */


/** 普通模型代理方法区 */

/** 接口地址 */
+(NSString *)baseModel_UrlString{
    return nil;
}

/** 请求方式 */
+(BaseModelHttpType)baseModel_HttpType{
    return BaseModelHttpTypeGET;
}

/** 是否需要本地缓存 */
+(BOOL)baseModel_NeedFMDB{
    return NO;
}

/** 缓存周期：单位秒 */
+(NSTimeInterval)baseModel_Duration{
    return 10;
}

/**
 *  错误数据解析：请求成功，但服务器返回的接口状态码抛出错误
 *
 *  @param hostData 服务器数据
 *
 *  @return 如果为nil，表示无错误；如果不为空表示有错误，并且为错误信息。
 */
+(NSString *)baseModel_parseErrorData:(id)hostData{
    return nil;
}

/** 服务器真正有用数据体：此时只是找到对应的key，还没有字典转模型 */
+(id)baseModel_findUsefullData:(id)hostData{
    return nil;
}

/** 返回数据格式 */
+(BaseModelHostDataType)baseModel_hostDataType{
    return BaseModelHostDataTypeModelSingle;
}




/** 分页模型代理方法区 */


/**
 *  是否为分页数据
 *
 *  @return 如果为分页模型请返回YES，否则返回NO
 */
+(BOOL)baseModel_isPageEnable{
    return NO;
}


/** page字段 */
+(NSString *)baseModel_PageKey{
    return @"page";
}


/** pagesize字段 */
+(NSString *)baseModel_PageSizeKey{
    return @"pagesize";
}


/** 页码起点 */
+(NSUInteger)baseModel_StartPage{
    return 1;
}


/** 每页数据量 */
+(NSUInteger)baseModel_PageSize{
    return 20;
}


@end
