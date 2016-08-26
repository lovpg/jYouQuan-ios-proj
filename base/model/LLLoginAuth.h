//
//  LLLoginAuth.h
//  Olla
//
//  Created by null on 14-11-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLLoginAuth : NSObject

@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *sessionId;
@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSString *server;
@property(nonatomic,strong) NSString *imserver;
@property(nonatomic,strong) NSString *liveToken;

- (NSString *)toString;

@end
