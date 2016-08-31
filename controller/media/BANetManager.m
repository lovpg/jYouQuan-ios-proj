

 
#import "BANetManager.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

/*! 系统相册 */
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>


#import <AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"

#import "UIImage+CompressImage.h"


static NSMutableArray *tasks;

@interface BANetManager ()

@end

@implementation BANetManager

/*!
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类BANetManager单例
 */
+ (instancetype)sharedBANetManager
{
    static BANetManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
        
    });
    return manager;
}

+ (AFHTTPSessionManager *)sharedAFManager
{
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        
        /*! 设置请求超时时间 */
        manager.requestSerializer.timeoutInterval = 30;
        
        /*! 设置相应的缓存策略：此处选择不用加载也可以使用自动缓存【注：只有get方法才能用此缓存策略，NSURLRequestReturnCacheDataDontLoad】 */
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        /*! 设置返回数据为json, 分别设置请求以及相应的序列化器 */
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;
        
        /*! 设置apikey ------类似于自己应用中的tokken---此处仅仅作为测试使用*/
        //        [manager.requestSerializer setValue:apikey forHTTPHeaderField:@"apikey"];
        
        /*! 复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        //        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        /*! 设置响应数据的基本了类型 */
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/xml",@"text/plain", @"application/javascript", nil];
        
        /*! https 参数配置 */
        /*! 
         采用默认的defaultPolicy就可以了. AFN默认的securityPolicy就是它, 不必另写代码. AFSecurityPolicy类中会调用苹果security.framework的机制去自行验证本次请求服务端放回的证书是否是经过正规签名. 
         */
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        manager.securityPolicy = securityPolicy;
        
        /*! 自定义的CA证书配置如下： */
        /*! 自定义security policy, 先前确保你的自定义CA证书已放入工程Bundle */
        /*! 
         https://api.github.com网址的证书实际上是正规CADigiCert签发的, 这里把Charles的CA根证书导入系统并设为信任后, 把Charles设为该网址的SSL Proxy (相当于"中间人"), 这样通过代理访问服务器返回将是由Charles伪CA签发的证书.
          */
//        NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
//        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
//        policy.allowInvalidCertificates = YES;
//        manager.securityPolicy = policy;
        
        /*! 如果服务端使用的是正规CA签发的证书, 那么以下几行就可去掉: */
//        NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
//        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
//        policy.allowInvalidCertificates = YES;
//        manager.securityPolicy = policy;
        
        
    });
    
    return manager;
}

+ (NSMutableArray *)tasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"创建数组");
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

#pragma mark - ***** 网络请求的类方法---get / post / put / delete


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
                 withUploadProgress:(BAUploadProgress)progress
{
    /*! 获得视频资源 */
//    AVURLAsset *avAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
//    
//    /*! 压缩 */
//    
//    //    NSString *const AVAssetExportPreset640x480;
//    //    NSString *const AVAssetExportPreset960x540;
//    //    NSString *const AVAssetExportPreset1280x720;
//    //    NSString *const AVAssetExportPreset1920x1080;
//    //    NSString *const AVAssetExportPreset3840x2160;
//    
//    AVAssetExportSession  *  avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
//    
//    /*! 创建日期格式化器 */
//    
//    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
//    
//    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
//    
//    /*! 转化后直接写入Library---caches */
//    
//    NSString *videoWritePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/output-%@.mp4",[formatter stringFromDate:[NSDate date]]]];
//    
//    
//    avAssetExport.outputURL = [NSURL URLWithString:videoWritePath];
//    
//    
//    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    
//    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
    
        
    [[self sharedAFManager]POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
        {
                    
        //获得沙盒中的视频内容
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:videoPath] name:@"write you want to writre" fileName:videoPath mimeType:@"video/mpeg4" error:nil];
                    
                    
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
        {
            NSLog(@"上传视频成功 = %@",responseObject);
            if (successBlock)
            {
               successBlock(responseObject);
            }
                    
                    
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
        {
            if (failureBlock)
            {
                failureBlock(error);
            }
                    
        }];
//    }];
}

#pragma mark - ***** 开始监听网络连接
/*!
 *  开启网络监测
 */
+ (void)ba_startNetWorkMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 当使用AF发送网络请求时,只要有网络操作,那么在状态栏(电池条)wifi符号旁边显示  菊花提示
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // 2.设置网络状态改变后的处理
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"未知网络");
                BANetManagerShare.netWorkStatus = BANetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                NSLog(@"没有网络");
                BANetManagerShare.netWorkStatus = BANetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"手机自带网络");
                BANetManagerShare.netWorkStatus = BANetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                BANetManagerShare.netWorkStatus = BANetworkStatusReachableViaWiFi;
                NSLog(@"WIFI--%lu", (unsigned long)BANetManagerShare.netWorkStatus);
                break;
        }
    }];
    [manager startMonitoring];
}

/*! 对图片尺寸进行压缩 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    if (newSize.height > 375/newSize.width*newSize.height)
    {
        newSize.height = 375/newSize.width*newSize.height;
    }
    
    if (newSize.width > 375)
    {
        newSize.width = 375;
    }
    
    UIImage *newImage = [UIImage needCenterImage:image size:newSize scale:1.0];
    
    return newImage;
}

+ (NSString *)strUTF8Encoding:(NSString *)str
{
    /*! ios9适配的话 打开第一个 */
    //return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
