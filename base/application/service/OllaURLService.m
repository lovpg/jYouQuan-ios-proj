//
//  OllaURLService.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaURLService.h"
#import "IOllaURLDownlinkTask.h"
#import "OllaAPIRequestTask.h"
#import "vender.h"
#import "system.h"

@interface OllaURLService (){

    NSOperationQueue *_operationQueue;
}

@end

@implementation OllaURLService

- (id)init{
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(BOOL)handle:(Protocol *)taskType task:(id<IOllaTask>)task priority:(NSInteger)priority{
    
    id<IOllaAPIRequestTask> urlTask = (id<IOllaAPIRequestTask>)task;
    NSString *url = [urlTask apiURL];
    if (!url) {
        url = [self.config objectForKey:[urlTask apiKey]];
    }
    
    
    if (taskType == @protocol(IOllaURLDownlinkTask)) {
        
        id<IOllaURLDownlinkTask,IOllaAPIRequestTask>urlTask = (id<IOllaURLDownlinkTask,IOllaAPIRequestTask>)task;
        
        NSString *pageIndex=[NSString stringWithFormat:@"%ud",[urlTask downlinkPageTaskPageIndex]];
        NSString *pageSize=[NSString stringWithFormat:@"%ud",[urlTask downlinkPageTaskPageSize]];
        [url stringByReplacingOccurrencesOfString:@"{pageIndex}" withString:pageIndex];
        [url stringByReplacingOccurrencesOfString:@"pageSize" withString:pageSize];
        
    }
    
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url relativeToURL:[self.config objectForKey:@"baseURL"] queryValues:[urlTask queryValue]]];
    request.allHTTPHeaderFields = [urlTask httpHeaders];
    request.HTTPMethod = [urlTask httpMethod];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id respondObject){
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:respondObject options:NSJSONReadingMutableLeaves error:nil];
        if (![result[@"status"] isEqualToString:@"200"]) {
            NSLog(@"API ERROR:code=%@,message=%@",result[@"status"],result[@"message"]);
            [[urlTask delegate] downlinkTaskDidFitalError:[[NSError alloc] initWithDomain:@"com.olla.api" code:[result[@"status"] intValue] userInfo:@{@"message":result[@"message"]}] forTaskType:@protocol(IOllaDownlinkTask) ];
        }
       
        [[urlTask delegate] downlinkTaskDidLoaded:result[@"data"] forTaskType:@protocol(IOllaDownlinkTask)];

        
        
    } failure:^(AFHTTPRequestOperation *operation ,NSError *error){
        NSLog(@"API ERROR:%@",[error userInfo]);
        
        [[urlTask delegate] downlinkTaskDidFitalError:error forTaskType:@protocol(IOllaDownlinkTask) ];
        
    }];
    
    
    [_operationQueue addOperation:operation];

    
    return NO;
}


@end
