//
//  OllaModel.m
//  OllaFramework
//
//  Created by null on 14-9-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaModel.h"

@implementation OllaModel

//每个model都重写这个方法, 数据库或网络数据根据这个字典，将数据映射到model中
//如果model中嵌套有OllaModel类型的数据类型，如llshare有llsimpleuser
+ (NSDictionary *)modelMap{
    return nil;
}

@end
