//
//  IOllaAuthContext.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOllaContext.h"

@protocol IOllaAuthContext <IOllaContext>

@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *sessionID;
@property(nonatomic,strong) NSString *username;

@end
