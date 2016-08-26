//
//  UIDevice+Hardware.m
//  FuShuo
//
//  Created by nonstriater on 14-1-26.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "UIDevice+Hardware.h"
#include <mach/mach.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <ifaddrs.h>
#include <mach/mach_host.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <dlfcn.h>


@implementation UIDevice (Hardware)

+ (void)playWithFileName:(NSString *)fileName {
    if (!fileName) {
        return;
    }
    
    NSString *audioPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) {
        SystemSoundID messageSound;
        CFURLRef audioURL = (__bridge  CFURLRef)[NSURL fileURLWithPath:audioPath];
        AudioServicesCreateSystemSoundID(audioURL, &messageSound);
        AudioServicesPlaySystemSound(messageSound);
    }
}

// CPU占用
- (NSString *)cpuUsage {
    
    kern_return_t			kr = { 0 };
    task_info_data_t		tinfo = { 0 };
    mach_msg_type_number_t	task_info_count = TASK_INFO_MAX;
    
    kr = task_info( mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count );
    if ( KERN_SUCCESS != kr )
        return @"";
    
    //	task_basic_info_t		basic_info = { 0 };
    thread_array_t			thread_list = { 0 };
    mach_msg_type_number_t	thread_count = { 0 };
    
    thread_info_data_t		thinfo = { 0 };
    thread_basic_info_t		basic_info_th = { 0 };
    
    //	basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads( mach_task_self(), &thread_list, &thread_count );
    if ( KERN_SUCCESS != kr )
        return @"";
    
    long	tot_sec = 0;
    long	tot_usec = 0;
    float	tot_cpu = 0;
    
    for ( int i = 0; i < thread_count; i++ ) {
        mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
        
        kr = thread_info( thread_list[i], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count );
        if ( KERN_SUCCESS != kr )
            return @"";
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if ( 0 == (basic_info_th->flags & TH_FLAGS_IDLE) ) {
            tot_sec		= tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec	= tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu		= tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }
    
    double usage = tot_cpu * 100;
    
    return [NSString stringWithFormat:@"%.1f%%",usage];
    
}

// 内存占用
- (NSString *)memoryUsage {
    
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    task_basic_info_data_t taskInfo;
    task_info(mach_task_self(),TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    
    double usage = taskInfo.resident_size / 1024.0 / 1024.0;
    
    return [NSString stringWithFormat:@"%0.2fMB",usage];
    
}

@end
