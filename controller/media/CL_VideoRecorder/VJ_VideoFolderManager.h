//
//  HYVideoFolderManager.h
//  test
//
//  Created by Vincent_Jac on 16/8/12.
//  Copyright © 2016年 Vincent_Jac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define VIDEO_FOLDER @"VJ_VideoFile"
@interface VJ_VideoFolderManager : NSObject

+ (CGFloat)fileSize:(NSURL *)path;

+ (NSString *)getVideoCompositionFilePathString;

+ (NSString *)getVideoMOVFilePathString;

+ (void) createVideoFolderIfNotExist;

+ (void) deleteRecordVideoCache;
@end
