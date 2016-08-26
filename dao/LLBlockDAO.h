//
//  LLBlockDAO.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

//与用户id无关，block的手机
@interface LLBlockDAO : NSObject

@property(nonatomic,assign,getter=isBlocked) BOOL blocked;

@end
