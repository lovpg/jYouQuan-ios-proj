//
//  OllaStyleParser.h
//  OllaFramework
//
//  Created by nonstriater on 14-8-13.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OllaStyleParser : NSObject

@property(nonatomic,strong,readonly) NSDictionary *styles;// @[label1:{};label2:{}]

+ (instancetype)sharePareser;

- (void)parseWithPath:(NSString *)path;


@end
