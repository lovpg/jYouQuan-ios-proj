//
//  LLShareService.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface LLShareService : NSObject

- (void)addShare:(NSString *)content
        location:(NSString *)location
            tags:(NSString *)tags
            city:(NSString *)city
         address:(NSString *)address
          images:(NSArray *) images
         success:(void (^)(AFHTTPRequestOperation *operation,id respondObject))success
            fail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail;

- (void)transfer:(NSString *)content
           title:(NSString *)title
            platform:(NSString *)platform
            url:(NSString *)url
        location:(NSString *)location
            tags:(NSString *)tags
            city:(NSString *)city
         address:(NSString *)address
          images:(NSArray *) images
         success:(void (^)(AFHTTPRequestOperation *operation,id respondObject))success
            fail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail;



@end
