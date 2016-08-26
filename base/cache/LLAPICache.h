//
//  LLAPICache.h
//  Olla
//
//  Created by Pat on 15/8/11.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "NSObject+Save.h"
#import "NSObject+Insert.h"
#import "NSObject+Create.h"
#import "NSObject+Update.h"
#import "NSObject+Delete.h"
#import "NSObject+Select.h"


extern NSString * const LLAPICacheIgnoreParamsKey;

@interface LLAPICache : NSObject

AS_SINGLETON(LLAPICache, sharedCache);

+ (void)setIdentifier:(NSString *)identifier;

- (void)setCacheArray:(NSArray *)array params:(NSDictionary *)params forURL:(NSString *)url;
- (void)setCacheData:(NSData *)data params:(NSDictionary *)params forURL:(NSString *)url;
- (NSArray *)cacheArrayWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz;
- (NSArray *)cacheArrayWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz orderBy:(NSString *)orderBy limit:(NSInteger)limit;

@end
