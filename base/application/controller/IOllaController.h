//
//  IOllaController.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaUIContext.h"

@protocol IOllaController <NSObject>

@property(nonatomic,weak) id<IOllaUIContext> context;


@optional
- (void)viewLoaded;

@end
