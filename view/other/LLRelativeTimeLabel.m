//
//  LLRelativeTimeLabel.m
//  Olla
//
//  Created by null on 14-9-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLRelativeTimeLabel.h"

@implementation LLRelativeTimeLabel

- (void)setTimestamp:(double)timestamp{
    
    if (_timestamp!=timestamp) {
        _timestamp  = timestamp;
        
        //java服务器时间戳单位是ms
        self.text = [[NSDate dateWithTimeIntervalSince1970:timestamp/1000] formatRelativeTime];
        
    }    
}


@end
