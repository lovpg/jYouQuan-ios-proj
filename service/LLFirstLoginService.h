//
//  LLFirstLoginService.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLFirstLoginDAO.h"

@interface LLFirstLoginService : NSObject{
    LLFirstLoginDAO *firstLoginDAO;
}

@property(nonatomic,assign,getter=isFirstLogin) BOOL firstLogin;

- (void)clear;


@end
