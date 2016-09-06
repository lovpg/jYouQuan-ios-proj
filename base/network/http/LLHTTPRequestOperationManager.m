//
//  LLHTTPRequestOperationManager.m
//  Olla
//
//  Created by nonstriater on 14-7-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLHTTPRequestOperationManager.h"
#import "JDStatusBarNotification.h"

@interface LLHTTPRequestOperationManager (){
    
}

@property(nonatomic,assign)  int errorDomainRetry;

// *****
@property (nonatomic, strong) NSMutableArray *goodListArr;
@property (nonatomic, strong) NSMutableArray *shareDetailArr;
// *****

@end

@implementation LLHTTPRequestOperationManager

// *****
- (NSMutableArray *)goodListArr {
    if (!_goodListArr) {
        _goodListArr = [NSMutableArray array];
    }
    return _goodListArr;
}

- (NSMutableArray *)shareDetailArr {
    if (!_shareDetailArr) {
        _shareDetailArr = [NSMutableArray array];
    }
    return _shareDetailArr;
}
// *****


+ (id)shareManager{
    
    static LLHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LLHTTPRequestOperationManager alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if(self = [super initWithBaseURL:[NSURL URLWithString: Olla_API_Base_URL]]){
        
        self.errorDomainRetry = 0;
        
        self.requestSerializer.timeoutInterval = 30.f;// 默认60s太长
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"version"];
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"market"];
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"secret"];
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"md5sum"];
        
        self.responseSerializer = [AFHTTPResponseSerializer serializer];//jsonSerializer接收的Content-Type支持3中： "text/json","application/json" "text/javascript"; AFHTTPResponseSerializer是nil
        
        
        self.securityPolicy.allowInvalidCertificates = YES;
        
    }
    return self;
}

- (void)setUserAuth:(LLLoginAuth *)userAuth{
    if (_userAuth != userAuth) {
        _userAuth = userAuth;
        
        [self.requestSerializer setValue:[userAuth toString] forHTTPHeaderField:@"Cookie"];
    }
}

- (AFHTTPRequestOperation *)GETListWithURL:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                 modelType:(Class )clazz
                                 needCache:(BOOL)needCache
                                   success:(void (^)(NSArray *datas , BOOL hasNext))success
                                   failure:(void (^)(NSError *error))failure {
    if (needCache)
    {
        NSDictionary *params = [self timestampParams:parameters];
        AFHTTPRequestOperation *operation = [self GETWithURL:URLString
                                                  parameters:params
                                                     success:^(id datas,BOOL hasNext)
        {
            
             if (![datas isArray])
             {
                 DDLogError(@"api(%@) must return array datas",URLString);
                 return ;
             }
             
             [[LLAPICache sharedCache] setCacheData:[datas JSONData] params:parameters forURL:URLString];
             NSMutableArray *array = [NSMutableArray array];
             for (NSDictionary *dict in datas) {
                 
                 NSDictionary *_dict = dict;
                 //如果clazz是ollamodel
                 if([[clazz class] isSubclassOfClass:[OllaModel class]]){
                     NSDictionary *map = [clazz modelMap];
                     if (map) {
                         _dict = [dict conversionWithModelMap:map];
                     }
                 }
                 
                 OllaModel *model = [_dict modelFromDictionaryWithClassName:clazz];
                 [array addObject:model];
             }
             success(array,hasNext);
             
         } failure:^(NSError *error){
             
             failure(error);
         }];
        
        return operation;

    }
    
    return [self GETListWithURL:URLString parameters:parameters modelType:clazz success:success failure:failure];
    
}

- (AFHTTPRequestOperation *)GETListWithURL:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                 modelType:(Class )clazz
                                   success:(void (^)(NSArray *datas , BOOL hasNext))success
                                   failure:(void (^)(NSError *error))failure{
    
    
    AFHTTPRequestOperation *operation = [self GETWithURL:URLString
                                              parameters:parameters
                                                 success:^(id datas,BOOL hasNext){
                                                     
                                                     if (![datas isArray]) {
                                                         DDLogError(@"api(%@) must return array datas",URLString);
                                                         return ;
                                                     }
                                                     
                                                     NSMutableArray *array = [NSMutableArray array];
                                                     for (NSDictionary *dict in datas) {
                                                         
                                                         NSDictionary *_dict = dict;
                                                         //如果clazz是ollamodel
                                                         if([[clazz class] isSubclassOfClass:[OllaModel class]]){
                                                             NSDictionary *map = [clazz modelMap];
                                                             if (map) {
                                                                 _dict = [dict conversionWithModelMap:map];
                                                             }
                                                         }
                                                         
                                                         OllaModel *model = [_dict modelFromDictionaryWithClassName:clazz];
                                                         [array addObject:model];
                                                     }
                                                     success(array,hasNext);
                                                     
                                                 } failure:^(NSError *error){
                                                     
                                                     failure(error);
                                                 }];
    
    return operation;
}

- (AFHTTPRequestOperation *)POSTListWithURL:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                 modelType:(Class )clazz
                                   success:(void (^)(NSArray *datas , BOOL hasNext))success
                                   failure:(void (^)(NSError *error))failure {
    
    
    AFHTTPRequestOperation *operation = [self POSTListWithURL:URLString
                                              parameters:parameters
                                                 success:^(id datas,BOOL hasNext){
                                                     
                                                     if (![datas isArray]) {
                                                         DDLogError(@"api(%@) must return array datas",URLString);
                                                         return ;
                                                     }
                                                     
                                                     NSMutableArray *array = [NSMutableArray array];
                                                     for (NSDictionary *dict in datas) {
                                                         
                                                         NSDictionary *_dict = dict;
                                                         //如果clazz是ollamodel
                                                         if([[clazz class] isSubclassOfClass:[OllaModel class]]){
                                                             NSDictionary *map = [clazz modelMap];
                                                             if (map) {
                                                                 _dict = [dict conversionWithModelMap:map];
                                                             }
                                                         }
                                                         
                                                         OllaModel *model = [_dict modelFromDictionaryWithClassName:clazz];
                                                         [array addObject:model];
                                                     }
                                                     success(array,hasNext);
                                                     
                                                 } failure:^(NSError *error){
                                                     
                                                     failure(error);
                                                 }];
    
    return operation;
}

// *****用于获取点赞列表
- (AFHTTPRequestOperation *)GETLikeListWithURL:(NSString *)URLString
                                    parameters:(NSDictionary *)parameters
                                     modelType:(Class )clazz
                                       success:(void (^)(NSArray *datas , BOOL hasNext))success
                                       failure:(void (^)(NSError *error))failure {
    
    AFHTTPRequestOperation *operation =
    [self GETWithURL:URLString
          parameters:parameters
             success:^(id datas,BOOL hasNext){
                 
                 if ([datas isDictionary]) {
                     
                     self.goodListArr = [[datas objectForKey:@"goodList"] mutableCopy];
                     
                     
                     NSMutableArray *array = [NSMutableArray array];
                     for (NSDictionary *dict in self.goodListArr) {
                         
                         NSDictionary *_dict = dict;
                         //如果clazz是ollamodel
                         if([[clazz class] isSubclassOfClass:[OllaModel class]]){
                             NSDictionary *map = [clazz modelMap];
                             if (map) {
                                 _dict = [dict conversionWithModelMap:map];
                             }
                         }
                         
                         OllaModel *model = [_dict modelFromDictionaryWithClassName:clazz];
                         [array addObject:model];
                     }
                     success(array, hasNext);
                 }
             } failure:^(NSError *error){
                 
                 failure(error);
             }];
    
    return operation;
}

// 用于获取帖子详情
- (AFHTTPRequestOperation *)GETShareDetailWithURL:(NSString *)URLString
                                       parameters:(NSDictionary *)parameters
                                        modelType:(Class )clazz
                                          success:(void (^)(NSArray *datas , BOOL hasNext))success
                                          failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperation *operation =
    [self GETWithURL:URLString
          parameters:parameters
             success:^(id datas,BOOL hasNext){
                 
                 if ([datas isDictionary]) {
                     
                     [self.shareDetailArr addObject:datas];
                     
                     NSMutableArray *array = [NSMutableArray array];
                     for (NSDictionary *dict in self.shareDetailArr) {
                         
                         NSDictionary *_dict = dict;
                         //如果clazz是ollamodel
                         if([[clazz class] isSubclassOfClass:[OllaModel class]]){
                             NSDictionary *map = [clazz modelMap];
                             if (map) {
                                 _dict = [dict conversionWithModelMap:map];
                             }
                         }
                         
                         OllaModel *model = [_dict modelFromDictionaryWithClassName:clazz];
                         [array addObject:model];
                     }
                     //                     NSLog(@"%@这是点赞列表的数组", array);
                     success(array, hasNext);
                 }
             } failure:^(NSError *error){
                 
                 failure(error);
             }];
    
    return operation;
}

- (AFHTTPRequestOperation *)GETWithURL:(NSString *)URLString
                            parameters:(NSDictionary *)parameters
                             modelType:(Class)clazz
                             needCache:(BOOL)needCache
                               success:(void (^)(OllaModel *model))success
                               failure:(void (^)(NSError *error))failure
{
    if (needCache)
    {
        return [self GETWithURL:URLString parameters:parameters modelType:clazz success:^(OllaModel *model)
        {
            [OllaModel save:model];
            success(model);
        }
        failure:failure];
    }
    
    return [self GETWithURL:URLString parameters:parameters modelType:clazz success:success failure:failure];
}

- (AFHTTPRequestOperation *)GETWithURL:(NSString *)URLString
                            parameters:(NSDictionary *)parameters
                             modelType:(Class)clazz
                               success:(void (^)(OllaModel *model))success
                               failure:(void (^)(NSError *error))failure {
    
    AFHTTPRequestOperation *operation = [self GETWithURL:URLString
                                              parameters:parameters
                                                 success:^(id data,BOOL hasNext){
                                                     
                                                     if (![data isKindOfClass:[NSDictionary class]]) {
                                                         DDLogError(@"api(%@) must return NSDictionary datas,but got:%@",URLString,data);
                                                         failure(nil) ;
                                                         return;
                                                     }
                                                     
                                                     id model =[data modelFromDictionaryWithClassName:clazz];
                                                     success(model);
                                                     
                                                 } failure:^(NSError *error){
                                                     
                                                     failure(error);
                                                     
                                                 }];
    
    return operation;
}

//基本异常处理
- (AFHTTPRequestOperation *)GETWithURL:(NSString *)URLString
                            parameters:(id)parameters
                               success:(void (^)(id datas , BOOL hasNext))success
                               failure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = [self timestampParams:parameters];
    __weak typeof(self) weakSelf = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPRequestOperation *operation = [[LLHTTPRequestOperationManager shareManager] GET:URLString parameters:params success:^(AFHTTPRequestOperation *operation,id respondObject){
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
// 数据量太大,容易引起 Logger Crash
//        DDLogInfo(@"API(%@) get Data:%@",URLString,[[NSString alloc] initWithData:respondObject encoding:NSUTF8StringEncoding]);
        NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:respondObject options:NSJSONReadingMutableLeaves error:nil];
        
        
        if (![datas[@"status"] isEqualToString:@"200"])
        {
            DDLogInfo(@"API error:datas status not 200:%@",datas);
            NSNumber *status = datas[@"status"];
            if ([self checkIfForceUpdate:datas[@"data"]
                                  status:status])
            {
                return;
            }
            //使用服务端的提示
            NSError *error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:datas];
            failure(error);//没必要上层处理这种错误，同一在这里处理
            return;
        }
        
        
        if (![datas isDictionary]) {// TODO: 这里要做异常处理，数据没有正确接收
            DDLogError(@"API error %@:datas not a dictinary", operation.request.URL);
            //[UIAlertView showWithTitle:nil message:@"Data error..." cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            //            [JDStatusBarNotification showWithStatus:@"Data error..." dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return ;
        }
        
        //数据字典异常检查和拦截?
        weakSelf.errorDomainRetry = 0;
        success(datas[@"data"],[datas[@"next"] boolValue]);
        
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        DDLogError(@"API(%@) error:%@",URLString, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //网络断开的问题
        if(![[AFNetworkReachabilityManager sharedManager] isReachable]){
            DDLogError(@"没有接入网络，检查下网络设置");
            [UIAlertView showWithTitle:nil message:@"网络不可用，请稍后再试." cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:nil];
            failure(nil);
            return;
        }
        
        //域名解析问题重试3次
        if ((error.code==NSURLErrorDNSLookupFailed || error.code==NSURLErrorCannotFindHost) && weakSelf.errorDomainRetry<3 ) {
            weakSelf.errorDomainRetry++;
            //调自身
            [weakSelf GETWithURL:URLString parameters:parameters success:success failure:failure];
        }
        if (error.code==NSURLErrorDNSLookupFailed || error.code == NSURLErrorCannotFindHost) {
            //[UIAlertView showWithTitle:nil message:@"DNS error" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            [JDStatusBarNotification showWithStatus:@"DNS error" dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return;
        }
        
        //超时处理
        //Error Domain=NSURLErrorDomain Code=-1001 "请求超时。" UserInfo=0x1943a570 {NSErrorFailingURLStringKey=https://olla.im/share/add.do, NSErrorFailingURLKey=https://olla.im/share/add.do, NSLocalizedDescription=请求超时。, NSUnderlyingError=0x195c9600 "请求超时。"}
        if (error.code == NSURLErrorTimedOut) {
            //[UIAlertView showWithTitle:nil message:@"Request Timeout" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            [JDStatusBarNotification showWithStatus:@"Request Timeout" dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return;
        }
        
        //非200，如404，502，503
        if (error.code == NSURLErrorBadServerResponse) {//404
            //[UIAlertView showWithTitle:nil message:@"Service Unavailable" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            [JDStatusBarNotification showWithStatus:@"Service Unavailable" dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return;
        }
        
        
        //其他错误处理
        //[UIAlertView showWithTitle:nil message:[self errorMessageWithMessage:error.userInfo[@"NSLocalizedDescription"]] cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
        NSString *errormsg = [NSString stringWithFormat:@"%@(code=%ld)",error.userInfo[@"NSLocalizedDescription"],(long)error.code];
        [JDStatusBarNotification showWithStatus:[self errorMessageWithMessage:errormsg] dismissAfter:1.f styleName:JDStatusBarStyleDark];
        failure(error);
        
    }];
    
    
    return operation;
}

- (AFHTTPRequestOperation *)POSTListWithURL:(NSString *)URLString
                            parameters:(id)parameters
                               success:(void (^)(id datas , BOOL hasNext))success
                               failure:(void (^)(NSError *error))failure{
    
    __weak typeof(self) weakSelf = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPRequestOperation *operation = [[LLHTTPRequestOperationManager shareManager] POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation,id respondObject){
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        DDLogInfo(@"API(%@) get Data:%@",URLString,[[NSString alloc] initWithData:respondObject encoding:NSUTF8StringEncoding]);
        NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:respondObject options:NSJSONReadingMutableLeaves error:nil];
        
        if (![datas isDictionary]) {// TODO: 这里要做异常处理，数据没有正确接收
            DDLogInfo(@"API error:datas not a dictinary");
            //[UIAlertView showWithTitle:nil message:@"Data error..." cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            //            [JDStatusBarNotification showWithStatus:@"Data error..." dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return ;
        }
        
        if (![datas[@"status"] isEqualToString:@"200"])
        {
            DDLogInfo(@"API error:datas status not 200:%@",datas);
            NSNumber *status = datas[@"status"];
            if ([self checkIfForceUpdate:datas[@"data"]
                                  status:status])
            {
                return;
            }
            //使用服务端的提示
            //#if DEBUG
            //            [UIAlertView showWithTitle:nil message:[self errorMessageWithMessage:datas[@"message"]] cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            //#endif
            NSError *error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:datas];
            failure(error);//没必要上层处理这种错误，同一在这里处理
            return;
        }
        
        //数据字典异常检查和拦截?
        weakSelf.errorDomainRetry = 0;
        success(datas[@"data"],[datas[@"next"] boolValue]);
        
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        DDLogError(@"API(%@) error:%@",URLString, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //网络断开的问题
        if(![[AFNetworkReachabilityManager sharedManager] isReachable]){
            DDLogError(@"没有接入网络，检查下网络设置");
            [UIAlertView showWithTitle:nil message:@"网络不可用，请稍后再试." cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:nil];
            failure(nil);
            return;
        }
        
        //域名解析问题重试3次
        if ((error.code==NSURLErrorDNSLookupFailed || error.code==NSURLErrorCannotFindHost) && weakSelf.errorDomainRetry<3 ) {
            weakSelf.errorDomainRetry++;
            //调自身
            [weakSelf GETWithURL:URLString parameters:parameters success:success failure:failure];
        }
        if (error.code==NSURLErrorDNSLookupFailed || error.code == NSURLErrorCannotFindHost) {
            //[UIAlertView showWithTitle:nil message:@"DNS error" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            [JDStatusBarNotification showWithStatus:@"DNS error" dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return;
        }
        
        //超时处理
        //Error Domain=NSURLErrorDomain Code=-1001 "请求超时。" UserInfo=0x1943a570 {NSErrorFailingURLStringKey=https://olla.im/share/add.do, NSErrorFailingURLKey=https://olla.im/share/add.do, NSLocalizedDescription=请求超时。, NSUnderlyingError=0x195c9600 "请求超时。"}
        if (error.code == NSURLErrorTimedOut) {
            //[UIAlertView showWithTitle:nil message:@"Request Timeout" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            [JDStatusBarNotification showWithStatus:@"Request Timeout" dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return;
        }
        
        //非200，如404，502，503
        if (error.code == NSURLErrorBadServerResponse) {//404
            //[UIAlertView showWithTitle:nil message:@"Service Unavailable" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
            [JDStatusBarNotification showWithStatus:@"Service Unavailable" dismissAfter:1.f styleName:JDStatusBarStyleDark];
            failure(nil);
            return;
        }
        
        
        //其他错误处理
        //[UIAlertView showWithTitle:nil message:[self errorMessageWithMessage:error.userInfo[@"NSLocalizedDescription"]] cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
        NSString *errormsg = [NSString stringWithFormat:@"%@(code=%ld)",error.userInfo[@"NSLocalizedDescription"],(long)error.code];
        [JDStatusBarNotification showWithStatus:[self errorMessageWithMessage:errormsg] dismissAfter:1.f styleName:JDStatusBarStyleDark];
        failure(error);
        
    }];
    
    
    return operation;
}


- (BOOL)checkIfForceUpdate:(NSDictionary *)dict
                    status:(NSNumber *) status
{
    if (status.integerValue == 1001 )
    {
        [self messageHandler:dict[@"tips"] url:dict[@"url"]];
        return YES;
    }
    return NO;
}


- (void) messageHandler: (NSString *)messgae
                    url: (NSString *)url
{
    [UIAlertView showWithTitle:@"升级提醒"
                       message:messgae
             cancelButtonTitle:@"放弃升级"
             otherButtonTitles:@[@"前往下载"]
                      tapBlock:^(UIAlertView *alertView,NSInteger tapIndex)
    {
        if (tapIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }];
}

- (BOOL)httpRespondCheckWithData:(NSDictionary *)datas whenError:(void (^)(NSError *error))errorBlock{
    
    
    if (![datas isDictionary]) {// TODO: 这里要做异常处理，数据没有正确接收
        DDLogInfo(@"API error:datas not a dictinary");
        //[UIAlertView showWithTitle:nil message:@"Data error..." cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
//        [JDStatusBarNotification showWithStatus:@"Data error..." dismissAfter:1.f styleName:JDStatusBarStyleDark];
        errorBlock(nil);
        return NO;
    }
    
    if (![datas[@"status"] isEqualToString:@"200"])
    {
        DDLogInfo(@"API error:datas status not 200:%@",datas);
        NSNumber *status = datas[@"status"];
        if ([self checkIfForceUpdate:datas[@"data"]
                              status:status])
        {
            return false;
        }
        //使用服务端的提示
        [UIAlertView showWithTitle:nil message:[self errorMessageWithMessage:datas[@"message"]] cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
        //[JDStatusBarNotification showWithStatus:datas[@"message"] dismissAfter:1.f styleName:JDStatusBarStyleDark];
        NSError *error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:@{@"message":datas[@"message"]}];
        errorBlock(error);//没必要上层处理这种错误，同一在这里处理
        return NO;
    }
    
    return YES;
    
}

- (void)httpRespondErrorHandler:(NSError *)error whenError:(void (^)(NSError *error))errorBlock{
    
    
    //网络断开的问题
    if(![[AFNetworkReachabilityManager sharedManager] isReachable]){
        DDLogError(@"没有接入网络，检查下网络设置");
        [UIAlertView showWithTitle:nil message:@"网络不可用，请稍后再试." cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:nil];
        errorBlock(nil);
        return;
    }
    
    //域名解析问题重试3次,
    if ((error.code==NSURLErrorDNSLookupFailed || error.code==NSURLErrorCannotFindHost) && self.errorDomainRetry<3 ) {
        self.errorDomainRetry++;
        //调自身
        //[self GETWithURL:URLString parameters:parameters success:success failure:failure];
    }
    if (error.code==NSURLErrorDNSLookupFailed || error.code == NSURLErrorCannotFindHost) {
        //[UIAlertView showWithTitle:nil message:@"DNS error" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
        [JDStatusBarNotification showWithStatus:@"DNS error" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        errorBlock(nil);
        return;
    }
    
    //超时处理
    //Error Domain=NSURLErrorDomain Code=-1001 "请求超时。" UserInfo=0x1943a570 {NSErrorFailingURLStringKey=https://olla.im/share/add.do, NSErrorFailingURLKey=https://olla.im/share/add.do, NSLocalizedDescription=请求超时。, NSUnderlyingError=0x195c9600 "请求超时。"}
    if (error.code == NSURLErrorTimedOut) {
        //[UIAlertView showWithTitle:nil message:@"Request Timeout" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
        [JDStatusBarNotification showWithStatus:@"Request Timeout" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        errorBlock(nil);
        return;
    }
    
    //非200，如404，502，503
    if (error.code == NSURLErrorBadServerResponse) {//404
        //[UIAlertView showWithTitle:nil message:@"Service Unavailable" cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
        [JDStatusBarNotification showWithStatus:@"Service Unavailable" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        errorBlock(nil);
        return;
    }
    
    
    //其他错误处理
    //[UIAlertView showWithTitle:nil message:[self errorMessageWithMessage:error.userInfo[@"NSLocalizedDescription"]] cancelButtonTitle:@"got it" otherButtonTitles:nil tapBlock:nil];
    NSString *errormsg = [NSString stringWithFormat:@"%@(code=%d)",error.userInfo[@"NSLocalizedDescription"],error.code];
    [JDStatusBarNotification showWithStatus:[self errorMessageWithMessage:errormsg] dismissAfter:1.f styleName:JDStatusBarStyleDark];
    errorBlock(error);
    
    
}



+ (void)GETSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock;{
    
    __block NSDictionary *respondDict;
    __block NSError *error;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[LLHTTPRequestOperationManager shareManager] GET:urlPath parameters:params success:^(AFHTTPRequestOperation *operation,id responsObject){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responsObject options:NSJSONReadingMutableLeaves error:nil];
        if (![dict isDictionary] ) {
            error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:@{@"message":@"respond data not a dictionary"}];
        }
        if (![dict[@"status"] isEqualToString:@"200"]) {
            error = [[NSError alloc] initWithDomain:@"com.olla.api" code:-1 userInfo:@{@"message":@"status not 200"}];
        }
        
        respondDict = dict[@"data"];
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        dispatch_semaphore_signal(semaphore);
    }];
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//阻塞线程，直到信号量大于0
    
    return completionBlock(respondDict,error);
    
}



// POST method //////////////////////////////////////////
- (AFHTTPRequestOperation *)POSTWithURL:(NSString *)URLString
                             parameters:(id)parameters
                                success:(void (^)(NSDictionary *responseObject))success
                                failure:(void (^)(NSError *error))failure{
    return [self POSTWithURL:URLString parameters:parameters images:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)POSTWithURL:(NSString *)URLString
                             parameters:(id)parameters
                                 images:(NSArray *)images
                                success:(void (^)(NSDictionary *responseObject))success
                                failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = [self timestampParams:parameters];
    AFHTTPRequestOperation * operation = [[LLHTTPRequestOperationManager shareManager]
                                          POST:URLString
                                          parameters:params
                                          constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
                                          {
                                                  for (UIImage *image in images) {
                                                      if (![image isKindOfClass:[UIImage class]]) {
                                                          continue ;
                                                      }
                                                      
                                                      [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.4) name:@"file" fileName:@"file.jpg" mimeType:@"multipart/form-data"];
                                                  }
                                              
                                          } success:^(AFHTTPRequestOperation *operation, id responseObject){
                                              
                                              NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                                              
                                              if (![dict[@"status"] isEqualToString:@"200"]) {
                                                  DDLogError(@"upload share error :%@",dict);
                                                  NSString *errorMessage = [LLAppHelper errorMessageWithError:[NSError errorWithDomain:@"com.olla.api" code:0 userInfo:dict]];
                                                  failure([[NSError alloc] initWithDomain:@"com.olla.api" code:0 userInfo:@{@"message":errorMessage}]);
                                                  return;
                                              }
                                              
                                              success(dict);
                                              
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                              failure(error);
                                          }];
    
    return operation;
    
}


- (AFHTTPRequestOperation *)POSTWithURL:(NSString *)URLString
                             parameters:(id)parameters
                                   data:(NSData *)data
                                success:(void (^)(NSDictionary *responseObject))success
                                failure:(void (^)(NSError *error))failure{
    
    NSDictionary *params = [self timestampParams:parameters];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPRequestOperation * operation = [[LLHTTPRequestOperationManager shareManager]
                                          POST:URLString
                                          parameters:params
                                          constructingBodyWithBlock:^(id <AFMultipartFormData> formData){
                                              [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"multipart/form-data"];
                                              
                                          }success:^(AFHTTPRequestOperation *operation, id responseObject){
                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                              NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                                              if([self httpRespondCheckWithData:datas whenError:failure]){
                                                  success(datas);
                                              }
                                              
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                              DDLogError(@"api error:%@",error);
                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                              [self httpRespondErrorHandler:error whenError:failure];
                                              
                                          }];
    
    return operation;
}

//比如用来上传崩溃日志
+ (void)POSTSync:(NSString *)urlPath params:(NSDictionary *)params complete:(void (^)(NSDictionary *respond,NSError *error))completionBlock{
    
}


// public  //////////////////////////////////////////////
- (NSString *)errorMessageWithMessage:(NSString *)message{
    NSString *errormsg = message;
    if (![message isString] || 0==[errormsg length]) {
        errormsg = @"There is something unnormal...";
    }
    
    return errormsg;
}


- (NSDictionary *)timestampParams:(NSDictionary *)params {
    NSMutableDictionary *newParams = nil;
    if (params) {
        newParams = [params mutableCopy];
    } else {
        newParams = [NSMutableDictionary dictionary];
    }
    NSNumber *timestamp = @([[NSDate date] timeIntervalSince1970]);
    [newParams setObject:timestamp forKey:@"timestamp"];
    return newParams;
}

- (void)dealloc{
    DDLogInfo(@"Dealloc:%@",self);
}


@end
