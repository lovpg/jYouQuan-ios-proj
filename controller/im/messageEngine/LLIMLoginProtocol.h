//
//  LLIMLoginProtocol.h
//  Olla
//
//  Created by null on 14-9-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLIMLoginProtocol <NSObject>

- (void)onLoginSuccess;

- (void)onLoginError:(NSError *)error;

- (void)onLogout;

- (BOOL)checkLogined;

@end
