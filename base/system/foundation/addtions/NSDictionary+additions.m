//
//  NSDictionary+additions.m
//  FuShuo
//
//  Created by nonstriater on 14-1-26.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "NSDictionary+additions.h"


@implementation NSDictionary (additions)

- (BOOL)check{
    return [self isKindOfClass:[NSDictionary class]];
}

- (NSMutableDictionary *)propertyListDictionary{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *key in [self allKeys]) {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSNull class]]) {
            value = @"";
        }
        if ([value isDictionary]) {
            value = [value propertyListDictionary];
        }
        [dictionary setValue:value forKey:key];
        
    }
    return dictionary;
}

- (id)modelFromDictionaryWithClassName:(Class)clazz{
    return [clazz objectWithKeyValues:self];
}

//T@"NSString",C,N,V_test ==> 属性名
- (NSString*) className:(NSString *)propertyTypeName {
    NSString* name = [[propertyTypeName componentsSeparatedByString:@","] objectAtIndex:0];
    NSString* cName = [[name substringToIndex:[name length]-1] substringFromIndex:3];
    return cName;
}



/**
 
 普通的：
 @{
 @"a":1,
 @"b":2
 }
 
 model map:
 @{
 @"a":@"A",
 @"b":@"B"
 }
 
 ====>
 retult:
 @{
 @"A":1,
 @"B":2
 }
 
 带嵌套时：
 
 @{
 @"a":1,
 @"b":@{@"c":2}
 }
 
 model map:
 @{
 @"a":@"A",
 @"b":@{@"c":@"C"}
 }
 
 ====>
 retult:
 @{
 @"A":1,
 @"b":@{@"C":2}
 }
 
 */
- (NSDictionary *)conversionWithModelMap:(NSDictionary *)map{
    
    if (!map) {
        return self;
    }
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (NSString *key in self.allKeys) {
        
        NSString *_key = key;
        
        id value = [map valueForKey:key];
        
        if ([value isNull]) {
            DDLogWarn(@"nil value detect for key:%@",_key);
            value = _key;
        }
        
        if ([value isDictionary]) {//嵌套
            
            value = [[self valueForKey:key] conversionWithModelMap:value];
        }
        
//        if (![value isString]) {
//            DDLogWarn(@"********* object map error ****** (%@->%@),程序自动转为(%@)",key,value,key);
//            value = _key;
//        }
//        
        if (value) {
            _key = value;
        }
        
        [results setValue:[self valueForKey:key] forKey:_key];
    }
    
    return results;
    
    // NSNumber, NSNull , NSString, NSDictionary,NSArray
}



@end
