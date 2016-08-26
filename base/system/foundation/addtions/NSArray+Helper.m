//
//  NSArray+Helper.m
//  Olla
//
//  Created by Pat on 15/7/22.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "NSArray+Helper.h"

@implementation NSArray (Helper)

+ (NSArray *)arrayWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    return [self arrayWithContentsOfFile:path];
}

@end
