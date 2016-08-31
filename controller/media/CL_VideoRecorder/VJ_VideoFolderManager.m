//
//  VJ_VideoFolderManager.m
//  test
//
//  Created by Vincent_Jac on 16/8/12.
//  Copyright © 2016年 Vincent_Jac. All rights reserved.
//

#import "VJ_VideoFolderManager.h"

@implementation VJ_VideoFolderManager

#pragma mark - 视频存储的文件操作

/**
 * 录制成功后的文件路径
 */
+ (NSString *)getVideoMOVFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    //从摄像头采集的初步数据，要在本地保存为mov格式，之后进行压缩
    NSString *fileName = [path stringByAppendingPathComponent:@"OrignVideo.mov"];
    return fileName;
}

/**
 * 压缩后的文件路径
 */
+ (NSString *)getVideoCompositionFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    NSString *fileName = [path stringByAppendingPathComponent:@"CompositionVideo.mp4"];
    return fileName;
}

/**
 * 压缩后的文件路径
 */
+ (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}

+ (void)createVideoFolderIfNotExist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建保存视频文件夹失败");
        }
    }
}

/**
 * 删除当前目录下的MOV、MP4文件缓存
 */
+ (void)deleteRecordVideoCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * filePath = [self getVideoMOVFilePathString];
        NSString * mp4Path = [self getVideoCompositionFilePathString];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"delete All Video 删除视频文件出错:%@", error);
            }
        }
        if([fileManager fileExistsAtPath:mp4Path]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:mp4Path error:&error];
            if (error) {
                NSLog(@"delete All Video 删除视频文件出错:%@", error);
            }
        }
    });
}

@end
