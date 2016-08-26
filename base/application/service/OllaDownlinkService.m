//
//  OllaDownlinkService.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-16.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaDownlinkService.h"

@implementation OllaDownlinkService

- (void)downlinkTaskDidLoadFromCache:(id<IOllaDownlinkTask>)downlinkTask forTaskType:(Protocol *)taskType{

    if ([downlinkTask respondsToSelector:@selector(downlinkTaskDidLoadedFromCache:timestamp:forTaskType:)]) {//ollaDataSource IOllaDownlinkTask
        
        
        
        
    }
}


- (void)downlinkTask:(id<IOllaDownlinkTask>)downlinkTask respondData:(id)data isCache:(BOOL)cache forTaskType:(Protocol *)taskType{

}

- (void)downlinkTask:(id<IOllaDownlinkTask>)task failedWithError:(NSError *)error forTaskType:(Protocol *)taskType{


}


@end
