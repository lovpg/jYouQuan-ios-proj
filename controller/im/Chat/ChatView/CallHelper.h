//
//  CallHelper.h
//  Olla
//
//  Created by Pat on 15/4/2.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface CallHelper : NSObject

AS_SINGLETON(CallHelper, sharedHelper);

@property (nonatomic, assign) BOOL isInIMChatView;

@end
