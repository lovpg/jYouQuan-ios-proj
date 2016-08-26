//
//  OllaEditImageView.h
//  OllaFramework
//
//  Created by nonstriater on 14/8/29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

// 支持图片选择(相册相机)，裁剪，压缩
// 一般同时多张图，都要使用多选功能，这个就用不上了
// 支持图片上传功能, 依赖业务系统中httpclient(有特定的http header等环境)
@interface OllaEditImageButton : UIButton

@property(nonatomic,assign) BOOL needHTTPUpload;


- (void)editImageWithPOSTURL:(NSString *)url OnSuccess:(void (^)(UIImage *image,NSString *url))successBlock onError:(void (^)(NSError *error))failBlock;


@end
