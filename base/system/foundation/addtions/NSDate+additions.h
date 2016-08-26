//
//  NSDate+additions.h
//  FuShuo
//
//  Created by nonstriater on 14-1-26.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (additions)

/**
 * Formats dates within 24 hours like '5 minutes ago', or calls formatDateTime if older.
 */
- (NSString*)formatRelativeTime;


//eg. 14:45 , 11月5 ,这里要用到NSDataFommater，从外部引入
- (NSString *)formatMouthRelativeTime:(NSDateFormatter *)formatter;

+ (NSTimeInterval)todayIntervalWithFormatter:(NSDateFormatter *)formatter;
- (NSString *)formatDetailRelativeTime;


- (BOOL)isTodayWithFormatter:(NSDateFormatter *)formatter;
- (NSString *)monthWithFormatter:(NSDateFormatter *)formatter;
- (NSString *)dayWithFormatter:(NSDateFormatter *)formatter;


@end
