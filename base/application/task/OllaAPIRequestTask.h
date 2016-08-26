//
//  OllaAPIRequestTask.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-12.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "IOllaTask.h"
#import "OllaTask.h"
#import "OllaAPIRequestTask.h"

@protocol IOllaAPIRequestTask <IOllaTask>

@property(nonatomic,strong) NSString *apiKey;
@property(nonatomic,strong) NSString *apiURL;
@property(nonatomic,strong) NSDictionary *queryValue;

@property(nonatomic,strong) NSString *httpMethod;
@property(nonatomic,strong) NSDictionary *httpHeaders;
@property(nonatomic,weak) id delegate;


@end

@interface OllaAPIRequestTask : OllaTask<IOllaAPIRequestTask>

@end
