//
//  OllaService.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaService.h"

@implementation OllaService

@synthesize config = _config;
@synthesize context = _context;

-(BOOL) handle:(Protocol *)taskType task:(id<IOllaTask>)task priority:(NSInteger)priority{
    return NO;
}

-(BOOL) cancelHandle:(Protocol *)taskType task:(id<IOllaTask>)task{
    return NO;
}

-(BOOL) cancelHandleForSource:(id) source{
    return NO;
}

-(void) didReceiveMemoryWarning{

}


@end
