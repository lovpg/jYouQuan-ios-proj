//
//  LLHTTPWriteOperationManager.h
//  Olla
//
//  Created by Pat on 15/9/11.
//  Copyright © 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLHTTPRequestOperationManager.h"

// 用于服务端 HTTP 写操作

@interface LLHTTPWriteOperationManager : LLHTTPRequestOperationManager

+ (instancetype)shareWriteManager;

@end
