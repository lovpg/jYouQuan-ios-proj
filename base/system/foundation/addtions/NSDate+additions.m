//
//  NSDate+additions.m
//  FuShuo
//
//  Created by nonstriater on 14-1-26.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "NSDate+additions.h"

@implementation NSDate (additions)


///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)formatRelativeTime {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self];
    
    if(timeInterval<60 && timeInterval>0){
        NSInteger timeInt=(NSInteger)timeInterval;
        return [NSString stringWithFormat:@"%ld 秒",(long)timeInt];
    }
    else if(timeInterval>=60 && timeInterval<3600){
        NSInteger timeInt=(NSInteger)timeInterval/60;
        return [NSString stringWithFormat:@"%ld 分钟前",(long)timeInt];
        
    }
    else if(timeInterval>=3600 && timeInterval<3600*24){
        NSInteger timeInt=(NSInteger)timeInterval/3600;
        return [NSString stringWithFormat:@"%ld 小时前",(long)timeInt];
        
    }
    //    else if(timeInterval>=3600*24 && timeInterval<3600*24*3){
    //        NSInteger timeInt=(NSInteger)timeInterval/(3600*24);
    //        return [NSString stringWithFormat:@"%ld day ago",(long)timeInt];
    //
    //    }
    else{
        NSInteger timeInt=(NSInteger)timeInterval/(3600*24);
        return [NSString stringWithFormat:@"%ld 天前",(long)timeInt];
        
    }
}


- (NSString *)formatMouthRelativeTime:(NSDateFormatter *)formatter{
    
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self];
    if (interval<3600*24) {//如果是当天发的
        [formatter setDateFormat:@"HH:mm"];
    }else{
        [formatter setDateFormat:@"MMM dd"]; // Jan 02
    }
    
    return [formatter stringFromDate:self];
    
}

+ (NSTimeInterval)todayIntervalWithFormatter:(NSDateFormatter *)formatter{
    
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSArray *times = [time componentsSeparatedByString:@":"];
    int hours=0,mins=0,sec=0;
    if ([times count]==3) {
        hours = [times[0] intValue];
        mins = [times[1] intValue];
        sec = [times[2] intValue];
    }
    
    return hours*60*60+mins*60 + sec;
    
}

- (NSString *)formatDetailRelativeTime{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self];
    NSTimeInterval todayInterval = [NSDate todayIntervalWithFormatter:formatter];
    if (interval<todayInterval) {//如果是当天发的
        [formatter setDateFormat:@"HH:mm"];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"]; // 12 02
    }
    
    return [formatter stringFromDate:self];
    
}

- (BOOL)isTodayWithFormatter:(NSDateFormatter *)formatter{
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self];
    NSTimeInterval todayInterval = [NSDate todayIntervalWithFormatter:formatter];
    if (interval<todayInterval) {//如果是当天发的
        return YES;
    }
    
    return NO;
}

- (NSString *)monthWithFormatter:(NSDateFormatter *)formatter{
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"MMM"];
     return [formatter stringFromDate:self];
}

- (NSString *)dayWithFormatter:(NSDateFormatter *)formatter{
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"dd"];
    return [formatter stringFromDate:self];
}


@end
