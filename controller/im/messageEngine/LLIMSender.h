//
//  LLIMSender.h
//  Olla
//
//  Created by null on 14-9-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLIMClient.h"
@interface LLIMSender : NSObject

@property(nonatomic,assign,readonly) BOOL isActive;

- (id)initWithIMClient:(LLIMClient *)client;

- (LLIMClient *)getClient;// 测试用

- (void)sendACK:(NSString *)msgid onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;

- (void)sendTextWithUid:(NSString *)uid msgid:(NSString *)msgid content:(NSString *)content onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;


- (void)sendImageWithUid:(NSString *)uid msgid:(NSString *)msgid content:(NSString *)content onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;


- (void)sendAudioWithUid:(NSString *)uid msgid:(NSString *)msgid content:(NSString *)content onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;


- (void)logout;
- (void)logoutOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;

// lucky
- (void)luckyLoginOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;
- (void)luckyNextOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;
- (void)luckyLogoutOnSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;
- (void)refuseUid:(NSString *)uid onSuccess:(MessageSuccessBlock)success onFail:(MessageFailureBlock)failure;



@end


