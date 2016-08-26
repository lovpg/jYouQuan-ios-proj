//
//  IOllaServiceContext.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaAuthContext.h"
#import "IOllaTask.h"

@protocol IOllaServiceContext <IOllaAuthContext>

- (BOOL)handle:(Protocol *)taskType task:(id<IOllaTask>)task priority:(NSInteger)priority;

-(BOOL) cancelHandle:(Protocol *)taskType task:(id<IOllaTask>)task;

-(BOOL) cancelHandleForSource:(id) source;

@end
