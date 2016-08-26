//
//  LLIMMessage.h
//  Olla
//
//  Created by null on 14-9-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLMessage.h"


@interface LLIMMessage : NSObject

@property(nonatomic,strong) LLMessage *message;
@property(nonatomic,strong) NSString *avatar;

@end
