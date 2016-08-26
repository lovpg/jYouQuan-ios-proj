//
//  LLCommentNotify.h
//  Olla
//
//  Created by nonstriater on 14/8/23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLUser.h"
#import "LLShare.h"
#import "LLComment.h"

@interface LLCommentNotify : NSObject<NSCoding>

//@property(nonatomic,strong) LLUser *user;
@property(nonatomic,strong) LLShare *share;
@property(nonatomic,strong) LLComment *comment;


@end
