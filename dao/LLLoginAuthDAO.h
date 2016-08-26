//
//  LLLoginAuthDAO.h
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLoginAuth.h"

// 负责登录信息的存储，加密
@interface LLLoginAuthDAO : NSObject

- (LLLoginAuth *)get;
- (BOOL)add:(LLLoginAuth *)auth;
- (BOOL)logout;


@end
