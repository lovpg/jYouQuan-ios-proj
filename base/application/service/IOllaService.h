//
//  IOllaService.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaServiceContext.h"

@protocol IOllaService <NSObject>

@property(nonatomic,strong) id config;
@property(nonatomic,assign) id<IOllaServiceContext> context;

-(BOOL) handle:(Protocol *)taskType task:(id<IOllaTask>)task priority:(NSInteger)priority;

-(BOOL) cancelHandle:(Protocol *)taskType task:(id<IOllaTask>)task;

-(BOOL) cancelHandleForSource:(id) source;

-(void) didReceiveMemoryWarning;


@end
