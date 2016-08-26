//
//  IOllaURLDownlinkTask.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaDownlinkPageTask.h"

@protocol IOllaURLDownlinkTask <IOllaDownlinkPageTask>

@property(nonatomic,strong) NSString *urlKey; // config.plst
@property(nonatomic,strong) NSString *url;


@end
