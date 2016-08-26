//
//  LLMessageReceiveListenerImpl.h
//  Olla
//
//  Created by null on 14-9-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLIMReceiveProtocol.h"
#import "LLBLockService.h"

// 收到消息
@interface LLMessageReceiveListenerImpl : NSObject<LLIMReceiveProtocol>{

    LLBLockService *blockService;
}


@end
