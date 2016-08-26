//
//  LLShareService.m
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLShareService.h"
#import "LLShareDAO.h"

@implementation LLShareService
{
    LLShareDAO *shareDao;
}

- (instancetype)init
{
    
    if (self=[super init])
    {
        shareDao = [[LLShareDAO alloc] init];
    }
    return self;
}

- (void)addShare:(NSString *)content
        location:(NSString *)location
            tags:(NSString *)tags
            city:(NSString *)city
         address:(NSString *)address
          images:(NSArray *) images
         success:(void (^)(AFHTTPRequestOperation *operation,id respondObject))success
            fail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail
{
    [shareDao addShare:content
              location:location
                  tags:tags
                  city:city
               address:address
                images:images
               success:^(AFHTTPRequestOperation *operation, id respondObject)
               {
                   success(operation, respondObject);
               }
               fail:^(AFHTTPRequestOperation *operation, NSError *error)
               {
                   fail(operation, error);
                }];
}

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
            fail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail
{
    [shareDao transfer:content
                 title:title
              platform:platform
                   url:url
              location:location
                  tags:tags
                  city:city
               address:address
                images:images
               success:^(AFHTTPRequestOperation *operation, id respondObject)
               {
                   success(operation, respondObject);
               }
               fail:^(AFHTTPRequestOperation *operation, NSError *error)
               {
                   fail(operation, error);
               }];
}

@end
