//
//  LLShareDAO.m
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLShareDAO.h"

@implementation LLShareDAO

/**
 *  获取一个share详情
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 */
- (void)get:(NSString *)sid success:(void (^)(LLShare *))success fail:(void (^)(NSError *))fail{

}

/**
 *  删除share
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 *
 *  @return
 */
- (void)deleteShare:(NSString *)sid success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail{

}

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
            fail:(void (^)(AFHTTPRequestOperation *operation,NSError *error))fail
{
    [[LLHTTPWriteOperationManager shareWriteManager]
     POST:Olla_API_Share_Add
     parameters:@{@"content":content,
                  @"location":location,
                  @"tags":tags,
                  @"city":city,
                  @"address":address,
                  }
     constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {// 一组图片上传！！
        
         for (id asset in images)
         {
             NSData *data = nil;
             if ([asset isKindOfClass:[UIImage class]])
             {
                 data = UIImageJPEGRepresentation(asset, 0.4);
             }
             if ([asset isKindOfClass:ALAsset.class])
             {
                 UIImage *original = [UIImage imageWithCGImage: [[asset defaultRepresentation] fullScreenImage]];
                 data = UIImageJPEGRepresentation(original, 0.4);
             }
             [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"multipart/form-data"];
         }
         
     }
     success:^(AFHTTPRequestOperation *operation,id respondObject)
     {
         success(operation, respondObject);
         
     }
     failure:^(AFHTTPRequestOperation *operation,NSError *error)
     {
        fail(operation,error);
     }];

}
/*****
 **
 ** 转载
 **
 ****/
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
{
    
    [[LLHTTPWriteOperationManager shareWriteManager]
     POST:@""
     parameters:@{@"content":content,
                  @"title":title,
                  @"platform":platform,
                  @"url":url,
                  @"location":location,
                  @"tags":tags,
                  @"city":city,
                  @"address":address,
                  }
     constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {// 一组图片上传！！
         
         for (id asset in images)
         {
             NSData *data = nil;
             if ([asset isKindOfClass:[UIImage class]])
             {
                 data = UIImageJPEGRepresentation(asset, 0.4);
             }
             if ([asset isKindOfClass:ALAsset.class])
             {
                 UIImage *original = [UIImage imageWithCGImage: [[asset defaultRepresentation] fullScreenImage]];
                 data = UIImageJPEGRepresentation(original, 0.4);
             }
             [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"multipart/form-data"];
         }
         
     }
     success:^(AFHTTPRequestOperation *operation,id respondObject)
     {
         success(operation, respondObject);
         
     }
     failure:^(AFHTTPRequestOperation *operation,NSError *error)
     {
         fail(operation,error);
     }];
    
}
/**
 *  给share 点赞
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 */
- (void)good:(NSString *)sid success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail{}

/**
 *  share 取消点赞
 *
 *  @param sid     share id
 *  @param success
 *  @param fail
 */
- (void)ungood:(NSString *)sid success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail{}

/**
 *  举报share
 *
 *  @param sid
 *  @param success
 *  @param fail
 */
- (void)report:(NSString *)sid success:(void (^)(NSDictionary *))success fail:(void (^)(NSError *))fail{}


@end
