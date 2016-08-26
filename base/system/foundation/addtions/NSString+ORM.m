//
//  NSString+ORM.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-28.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "NSString+ORM.h"
#import "NSDictionary+additions.h"

@implementation NSString (ORM)


//JSONKit，不支持arc
- (id)modelFromJSONWithClassName:(Class)clazz{
    
    if (self.length == 0) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"JSON Read ERROR:%@",error);
        return nil;
    }
    
    return [dict modelFromDictionaryWithClassName:clazz];

}

// 重写 NSObject+check
- (NSDictionary *)dictionaryRepresentation{

    NSError *error= nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"JSON parse ERROR:%@",error);
    }
    
    return dict;
}


@end
