//
//  LLHTTPWriteOperationManager.m
//  Olla
//
//  Created by Pat on 15/9/11.
//  Copyright © 2015年 xiaoran. All rights reserved.
//

#import "LLHTTPWriteOperationManager.h"

@implementation LLHTTPWriteOperationManager

+ (instancetype)shareWriteManager
{
    static LLHTTPWriteOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[LLHTTPWriteOperationManager alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    self = [super init];
    
    if (self) {
        self.baseURL = [NSURL URLWithString:[LLAppHelper writeOperationURL]];
    }
    
    return self;
}


@end
