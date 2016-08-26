//
//  BaseModel.h
//  4s
//
//  Created by muxi on 15/3/11.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModelProtocol.h"
#import "BasePageModelProtocol.h"
#import "NSObject+Insert.h"
#import "NSObject+Save.h"
#import "NSObject+Delete.h"
#import "NSObject+Update.h"
#import "NSObject+Select.h"

@interface BaseModel : NSObject<BaseModelProtocol,BasePageModelProtocol>


/** 服务器数据的ID */
@property (nonatomic,strong) NSString *hostId;


/** 父级模型名称：此属性用于完成级联添加以及查询，框架将自动处理，请不要手动修改！ */
@property (nonatomic,strong) NSString *pModel;


/** 父模型的hostId：此属性用于完成级联添加以及查询，框架将自动处理，请不要手动修改！ */
@property (nonatomic,strong) NSString* pid;

@property (nonatomic,strong) NSString *ollaURL;

@property (nonatomic,assign) double updateTime;


/** 模型对比时需要忽略的字段 */
+(NSArray *)constrastIgnorFields;
-(NSString *)uniqueId;

@end
