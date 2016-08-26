//
//  Singleton.h
//  ChineseStrokesOrder
//
//  Created by Pat on 14/11/6.
//  Copyright (c) 2014年 Pat. All rights reserved.
//

#ifndef ChineseStrokesOrder_Singleton_h
#define ChineseStrokesOrder_Singleton_h

#define AS_SINGLETON( __class , __method) \
+ (__class *)__method;


#define DEF_SINGLETON( __class , __method ) \
+ (__class *)__method {\
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

#endif
