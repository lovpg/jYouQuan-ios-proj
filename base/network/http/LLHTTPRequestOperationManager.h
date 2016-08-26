//
//  LLHTTPRequestOperationManager.h
//  Olla
//
//  Created by nonstriater on 14-7-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLoginAuth.h"

typedef void (^Callback)(id obj);

@interface LLHTTPRequestOperationManager : AFHTTPRequestOperationManager

@property(nonatomic,strong) LLLoginAuth *userAuth;

+ (id)shareManager;


- (void)setBaseURL:(NSURL *)baseURL;

//DNS error 重试，服务端数据解析判断逻辑
//注意，图片文件，语音文件下载还是用 GET api， respondObject并非字典
- (AFHTTPRequestOperation *)GETWithURL:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(id datas , BOOL hasNext))success
                        failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)GETWithURL:(NSString *)URLString
        parameters:(NSDictionary *)parameters
         modelType:(Class)clazz
           success:(void (^)(OllaModel *model))success
           failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)GETWithURL:(NSString *)URLString
                            parameters:(NSDictionary *)parameters
                             modelType:(Class)clazz
                             needCache:(BOOL)needCache
                               success:(void (^)(OllaModel *model))success
                               failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)GETListWithURL:(NSString *)URLString
            parameters:(NSDictionary *)parameters
             modelType:(Class )clazz
               success:(void (^)(NSArray *datas , BOOL hasNext))success
               failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)GETListWithURL:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                 modelType:(Class )clazz
                                 needCache:(BOOL)needCache
                                   success:(void (^)(NSArray *datas , BOOL hasNext))success
                                   failure:(void (^)(NSError *error))failure;


- (AFHTTPRequestOperation *)POSTListWithURL:(NSString *)URLString
                                 parameters:(NSDictionary *)parameters
                                  modelType:(Class )clazz
                                    success:(void (^)(NSArray *datas , BOOL hasNext))success
                                    failure:(void (^)(NSError *error))failure;
// 多种数组的情况



// 数组加字典的情况

- (AFHTTPRequestOperation *)POSTWithURL:(NSString *)URLString
        parameters:(id)parameters
           success:(void (^)(NSDictionary *responseObject))success
           failure:(void (^)(NSError *error))failure;


- (AFHTTPRequestOperation *)POSTWithURL:(NSString *)URLString
         parameters:(id)parameters
             images:(NSArray *)images
            success:(void (^)(NSDictionary *responseObject))success
            failure:(void (^)(NSError *error))failure;


- (AFHTTPRequestOperation *)POSTWithURL:(NSString *)URLString
         parameters:(id)parameters
             data:(NSData *)data
            success:(void (^)(NSDictionary *responseObject))success
            failure:(void (^)(NSError *error))failure;


// ///////同步方法////////////////////////////////////////////////

//- (void)GET:(NSString *)url params:(NSDictionary *)params;
+ (void)GETSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock;


+ (void)POSTSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock;


// /////////////////////////////////////////////////////////////
- (BOOL)checkIfForceUpdate:(NSDictionary *)dict
                    status:(NSNumber *)status;

// *****用于获取点赞列表
- (AFHTTPRequestOperation *)GETLikeListWithURL:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                 modelType:(Class )clazz
                                   success:(void (^)(NSArray *datas , BOOL hasNext))success
                                   failure:(void (^)(NSError *error))failure;


// 用于获取帖子详情
- (AFHTTPRequestOperation *)GETShareDetailWithURL:(NSString *)URLString
                                    parameters:(NSDictionary *)parameters
                                     modelType:(Class )clazz
                                       success:(void (^)(NSArray *datas , BOOL hasNext))success
                                          failure:(void (^)(NSError *error))failure;



@end
