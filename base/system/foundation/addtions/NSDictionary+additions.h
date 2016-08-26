//
//  NSDictionary+additions.h
//  FuShuo
//
//  Created by nonstriater on 14-1-26.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (additions)

- (BOOL)check;
- (NSMutableDictionary *)propertyListDictionary;
- (id)modelFromDictionaryWithClassName:(Class)clazz;
    
- (NSDictionary *)conversionWithModelMap:(NSDictionary *)map;

@end
