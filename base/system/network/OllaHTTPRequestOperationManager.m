//
//  LLHTTPRequestOperationManager.m
//  Olla
//
//  Created by nonstriater on 14-7-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaHTTPRequestOperationManager.h"

@implementation OllaHTTPRequestOperationManager

+ (id)shareManager{
    
    static OllaHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OllaHTTPRequestOperationManager alloc] init];
    });

    
    return sharedInstance;
}

- (id)init{
    if(self = [super initWithBaseURL:[NSURL URLWithString: nil]]){
        
        self.requestSerializer.timeoutInterval = 15.f;// 默认60s太长
        
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"version"];
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"market"];
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"secret"];
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"md5sum"];
        
        self.responseSerializer = [AFHTTPResponseSerializer serializer];// jsonSerializer接收的Content-Type支持3中： "text/json","application/json"   "text/javascript"; AFHTTPResponseSerializer是nil
        
        
        self.securityPolicy.allowInvalidCertificates = YES;
        
    }
    return self;
}


+ (void)GETSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock;{
    
    __block NSDictionary *respondDict;
    __block NSError *error;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[OllaHTTPRequestOperationManager shareManager] GET:urlPath parameters:params success:^(AFHTTPRequestOperation *operation,id responsObject){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responsObject options:NSJSONReadingMutableLeaves error:nil];
        if (![dict isDictionary] ) {
            error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:@{@"message":@"respond data not a dictionary"}];
            completionBlock(nil,error);
            return ;
        }
        if (![dict[@"status"] isEqualToString:@"200"]) {
            error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:@{@"message":@"status not 200"}];
            completionBlock(nil,error);
            return ;
        }
        
        respondDict = dict[@"data"];
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        dispatch_semaphore_signal(semaphore);
        
    }];
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//阻塞线程，直到信号量大于0
    
    return completionBlock(respondDict,error);

}



+ (void)POSTSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock{
    
    __block NSDictionary *respondDict;
    __block NSError *error;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[OllaHTTPRequestOperationManager shareManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation,id responsObject){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responsObject options:NSJSONReadingMutableLeaves error:nil];
        
        if (![dict isDictionary] ) {
            error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:@{@"message":@"respond data not a dictionary"}];
            completionBlock(nil,error);
            return ;
        }
        if (![dict[@"status"] isEqualToString:@"200"]) {
            error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:@{@"message":@"status not 200"}];
            completionBlock(nil,error);
            return;
        }
        
        respondDict = dict;
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        dispatch_semaphore_signal(semaphore);
    }];
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//阻塞线程，直到信号量大于0
    
    return completionBlock(respondDict,error);

}



- (void)dealloc{
    NSLog(@"Dealloc:%@",self);
}


@end
