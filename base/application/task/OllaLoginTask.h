//
//  OllaLoginTask.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-12.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaTask.h"

@protocol OllaLoginTask <IOllaTask>

@required
- (NSString *)loginPassword;
- (NSString *)loginAccount;
@optional

- (void)loginTaskSuccess:(id)context;
- (void)loginTaskFailWithError:(NSError *)error;

@end
