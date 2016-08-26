//
//  LLHTTPRequestOperationManager.h
//  Olla
//
//  Created by nonstriater on 14-7-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OllaHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (id)shareManager;

//- (void)GET:(NSString *)url params:(NSDictionary *)params;
+ (void)GETSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock;

+ (void)POSTSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock;

@end
