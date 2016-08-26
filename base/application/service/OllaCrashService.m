//
//  OllaCrashService.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaCrashService.h"
#import "OllaTask.h"

@protocol IOllaCrashTask <IOllaTask>

@property(nonatomic, strong) NSException *exception;

@end

@interface OllaCrashTask : OllaTask<IOllaCrashTask>

@end

@implementation OllaCrashTask

@synthesize exception = _exception;

@end



static OllaCrashService *gOllaCrashService = nil;

static void crashServiceUncaughtExceptionHandler(NSException *exception){

    OllaCrashTask *crashTask = [[OllaCrashTask alloc] init];
    [crashTask setException:exception];
    [gOllaCrashService.context handle:@protocol(IOllaCrashTask) task:crashTask priority:0];
    
}

static void crashServiceSignalHandler(int signal){

    NSException *exception = [[NSException alloc] initWithName:@"com.olla.OllaCrashServiceSignal" reason:[NSString stringWithFormat:@"signal:%d, errno:%d",signal,errno] userInfo:nil];
    [exception raise];
}


@implementation OllaCrashService

- (id)init{
    if (self=[super init]) {
        NSSetUncaughtExceptionHandler(crashServiceUncaughtExceptionHandler);
        
        signal(SIGABRT, crashServiceSignalHandler);
        signal(SIGILL, crashServiceSignalHandler);
        signal(SIGSEGV, crashServiceSignalHandler);
        signal(SIGFPE, crashServiceSignalHandler);
        signal(SIGBUS, crashServiceSignalHandler);
        signal(SIGPIPE, crashServiceSignalHandler);
        
        gOllaCrashService = self;
        
    }
    return self;
}


- (BOOL)handle:(Protocol *)taskType task:(id<IOllaTask>)task priority:(NSInteger)priority{
    
    if (@protocol(IOllaCrashTask) == taskType) {
        
        NSException *exception = [(id<IOllaCrashTask>)task exception];
        if (exception) {//发给bug服务器
         
            
            
        }
        return YES;
    }
  
    return NO;
}




@end
