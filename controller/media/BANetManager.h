

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define BANetManagerShare [BANetManager sharedBANetManager]

/*! 使用枚举NS_ENUM:区别可判断编译器是否支持新式枚举,支持就使用新的,否则使用旧的 */
typedef NS_ENUM(NSUInteger, BANetworkStatus)
{
    /*! 未知网络 */
    BANetworkStatusUnknown           = 0,
    /*! 没有网络 */
    BANetworkStatusNotReachable,
    /*! 手机自带网络 */
    BANetworkStatusReachableViaWWAN,
    /*! wifi */
    BANetworkStatusReachableViaWiFi
};

/*！定义请求类型的枚举 */
typedef NS_ENUM(NSUInteger, BAHttpRequestType)
{
    /*! get请求 */
    BAHttpRequestTypeGet = 0,
    /*! post请求 */
    BAHttpRequestTypePost,
    /*! put请求 */
    BAHttpRequestTypePut,
    /*! delete请求 */
    BAHttpRequestTypeDelete
    
    
};

/*! 定义请求成功的block */
typedef void( ^ BAResponseSuccess)(id response);
/*! 定义请求失败的block */
typedef void( ^ BAResponseFail)(NSError *error);

/*! 定义上传进度block */
typedef void( ^ BAUploadProgress)(int64_t bytesProgress,
                                  int64_t totalBytesProgress);
/*! 定义下载进度block */
typedef void( ^ BADownloadProgress)(int64_t bytesProgress,
                                    int64_t totalBytesProgress);

/*!
 *  方便管理请求任务。执行取消，暂停，继续等任务.
 *  - (void)cancel，取消任务
 *  - (void)suspend，暂停任务
 *  - (void)resume，继续任务
 */
typedef NSURLSessionTask BAURLSessionTask;



@interface BANetManager : NSObject

/*! 获取当前网络状态 */
@property (nonatomic, assign) BANetworkStatus   netWorkStatus;

/*!
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类BANetManager单例
 */
+ (instancetype)sharedBANetManager;

/*!
 *  开启网络监测
 */
+ (void)ba_startNetWorkMonitoring;

/*!
 *  网络请求方法,block回调
 *
 *  @param type         get / post
 *  @param urlString    请求的地址
 *  @param paraments    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 *  @param progress 进度
 */
+ (BAURLSessionTask *)ba_requestWithType:(BAHttpRequestType)type
                           withUrlString:(NSString *)urlString
                          withParameters:(NSDictionary *)parameters
                        withSuccessBlock:(BAResponseSuccess)successBlock
                        withFailureBlock:(BAResponseFail)failureBlock
                                progress:(BADownloadProgress)progress;

/*!
 *  视频上传
 *
 *  @param operations   上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString     上传的url
 *  @param successBlock 成功的回调
 *  @param failureBlock 失败的回调
 *  @param progress     上传的进度
 */
+ (void)ba_uploadVideoWithUrlString:(NSString *)urlString
                         parameters:(NSDictionary *)parameters
                      withVideoPath:(NSString *)videoPath
                   withSuccessBlock:(BAResponseSuccess)successBlock
                   withFailureBlock:(BAResponseFail)failureBlock
                 withUploadProgress:(BAUploadProgress)progress;



@end
