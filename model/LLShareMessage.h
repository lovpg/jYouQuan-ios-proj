//
//  LLShareMessage.h
//  Olla
//
//  Created by Pat on 15/7/31.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLShare.h"
#import "LLComment.h"

static NSString *LLShareMessageTypeComment = @"comment";
static NSString *LLShareMessageTypeLike    = @"shareGood";

@interface LLShareMessage : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) LLUser *user;
@property (nonatomic, strong) LLComment *comment;
@property (nonatomic, strong) LLShare *share;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *shareId;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *date;

@end
