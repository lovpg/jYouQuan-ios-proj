//
//  LLIMReceiveProtocol.h
//  Olla
//
//  Created by null on 14-9-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLIMReceiveProtocol <NSObject>


- (void)onReceive:(NSDictionary *)map;

- (void)onNews:(NSDictionary * )map;

- (void)onKick:(NSDictionary *)map;

- (void)onOffline:(NSDictionary *)map;

- (void)onLucky:(NSDictionary *)map;


@end
