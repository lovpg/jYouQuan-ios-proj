//
//  OllaAuthContext.h
//  Olla
//
//  Created by null on 14-10-18.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OllaAuthContext : NSObject<IOllaAuthContext>

+ (OllaAuthContext *)authContextWithString:(NSString *)string;
- (NSString *)toString;

@end
