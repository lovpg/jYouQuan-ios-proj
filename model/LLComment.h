//
//  LLComment.h
//  Olla
//
//  Created by nonstriater on 14/8/23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLSimpleUser.h"

@interface LLComment : OllaModel<NSCoding>

@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *objUsername;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *shareId;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *voice;  // 语音url
@property (nonatomic, strong) NSString *vlen;  // 语音长度 单位:秒
@property (nonatomic, assign) double posttime;

@property (nonatomic, strong) NSArray *imageList;

@property (nonatomic, strong) LLSimpleUser *user;



@end
