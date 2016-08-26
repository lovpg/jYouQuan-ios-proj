//
//  IOllaServiceContainer.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaServiceContext.h"

@protocol IOllaServiceContainer <NSObject>

@property(nonatomic,strong,readonly) id instance;
@property(nonatomic,strong) id config;
@property(nonatomic,strong) id<IOllaServiceContext> context;

-(BOOL) hasTaskType:(Protocol *) taskType;

-(void) addTaskType:(Protocol *) taskType;

-(void) didReceiveMemoryWarning;

@end
