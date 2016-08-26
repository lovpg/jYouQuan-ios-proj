//
//  LLIMClientLogin.h
//  Olla
//
//  Created by null on 14-9-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMSocket.h"
#import "LLIMLoginProtocol.h"

@interface LLIMClientLogin : LLIMSocket<LLIMLoginProtocol>

@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *password;

@property(nonatomic,assign) long sessionID;//

- (void)logout;


@end
