//
//  LLFirstLoginDAO.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLFirstLoginDAO : NSObject

@property(nonatomic,assign,getter=isFirstLogin) BOOL firstLogin;

- (void)clear;

@end
