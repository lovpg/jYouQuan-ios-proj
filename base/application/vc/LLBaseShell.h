//
//  OllaShell.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaUIContext.h"

@interface LLBaseShell : NSObject<IOllaUIContext>

@property(nonatomic, strong, readonly)id config;

- (id)initWithConfig:(id)config bundle:(NSBundle *)bundle;

@end
