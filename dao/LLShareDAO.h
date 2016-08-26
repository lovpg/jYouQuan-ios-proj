//
//  LLShareDAO.h
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLShare.h"

@interface LLShareDAO : NSObject

/**
 *  获取一个share详情
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 */
- (void)get:(NSString *)sid
    success:(void (^)(LLShare *))
success fail:(void (^)(NSError *))fail;

/**
 *  删除share
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 *
 *  @return
 */
- (void)deleteShare:(NSString *)sid
            success:(void (^)(NSDictionary *))success
               fail:(void (^)(NSError *))fail;

/**
 *  添加一条图文的share
 *
 *  @param text    share 文字内容
 *  @param images  share 图片信息
 *  @param success
 *  @param fail
 */
- (void)addShare:(NSString *)content
        location:(NSString *)location
            tags:(NSString *)tags
            city:(NSString *)city
         address:(NSString *)address
          images:(NSArray *) images
         success:(void (^)(AFHTTPRequestOperation *operation,id respondObject))success
            fail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail;

/**
 *  转载
 *
 *  @param text    share 文字内容
 *  @param images  share 图片信息
 *  @param success
 *  @param fail
 */
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

/**
 *  给share 点赞
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 */
- (void)good:(NSString *)sid success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail;

/**
 *  share 取消点赞
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 */
- (void)ungood:(NSString *)sid success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail;

/**
 *  举报share
 *
 *  @param sid
 *  @param success
 *  @param fail
 */
- (void)report:(NSString *)sid success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail;

/**
 *  评论一条share
 *
 *  @param sid     sid
 *  @param content 评论内容
 *  @param success
 *  @param fail
 */
- (void)comment:(NSString *)sid content:(NSString *)content success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail;



@end


