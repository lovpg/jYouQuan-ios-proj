//
//  LLLocalCommandContext.h
//  Olla
//
//  Created by null on 14-9-28.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLLocalCommandContext : NSObject

- (void)onReciveCommand:(NSString *)command option:(NSString *)option;

@end
