//
//  LLBLockService.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLBlockDAO.h"

@interface LLBLockService : NSObject{

    LLBlockDAO *blockDAO;
}

@property(nonatomic,assign,getter=isBlocked) BOOL blocked;

@end
