//
//  __macro__.h
//
//  Created by null on 14-10-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#ifndef Olla___macro___h
#define Olla___macro___h


#undef __ON__
#define __ON__ (1)

#undef __OFF__
#define __OFF__ (0)


#define __OLLA_LOG__ (__ON__)
#if defined(__OLLA_LOG__) && __OLLA_LOG__
#define NSLog(fmt,...) NSLog((@"%s,%s:%d    " fmt),__FILE__,__PRETTY_FUNCTION__,__LINE__, ##__VA_ARGS__)
#else
#define NSLog(...) {}
#endif



#if __IPHONE_6_0
#endif

#if __has_feature(objc_arc)
#else
#endif


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IOS6 [[[UIDevice currentDevice] systemVersion] hasPrefix:@"6"]
#define IS_IOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
#define IS_IOS8 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")
#define IS_3_5 ([[UIScreen mainScreen] bounds].size.height==480)

#define IS_IPHONE ([[ [ UIDevice currentDevice ] model ] rangeOfString:@"iPhone"].location != NSNotFound)
#define IS_IPAD ([[ [ UIDevice currentDevice ] model ] rangeOfString:@"iPad"].location != NSNotFound)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define Screen_Height [[UIScreen mainScreen] bounds].size.height
#define Screen_Width [[UIScreen mainScreen] bounds].size.width
#define View_Height IS_IOS7?(Screen_Height):(Screen_Height-20)

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"

#define CHATVIEWBACKGROUNDCOLOR [UIColor colorWithRed:0.936 green:0.932 blue:0.907 alpha:1]


#endif



