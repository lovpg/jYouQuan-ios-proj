//
//  OllaLoginService.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-12.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaLoginService.h"
#import "OllaAPIRequestTask.h"
#import "IOllaDownlinkTask.h"

@implementation OllaLoginService

- (BOOL)handle:(Protocol *)taskType task:(id<IOllaTask>)task priority:(NSInteger)priority{

    if (taskType == @protocol(OllaLoginTask)) {
        
        id<OllaLoginTask> loginTask = (id<OllaLoginTask>)task;
        NSString *account = [loginTask loginAccount];
        NSString *password = [loginTask loginPassword];
        
        if ([account length]==0 || [password length]==0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"I know" otherButtonTitles: nil];
            [alertView show];
        }

        OllaAPIRequestTask *task = [[OllaAPIRequestTask alloc] init];
        task.apiKey = @"login";
        task.queryValue = @{@"username":account,@"password":password};
        task.httpMethod = @"GET";
        task.httpHeaders = @{};
        task.delegate = loginTask;
        
        [self.context handle:@protocol(IOllaDownlinkTask) task:task priority:0];
    }
    
    return NO;
}

- (BOOL)cancelHandle:(Protocol *)taskType task:(id<IOllaTask>)task{
    return NO;
}

@end
