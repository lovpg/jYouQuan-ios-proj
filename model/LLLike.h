//
//  LLLike.h
//  Olla
//
//  Created by Charles on 15/4/27.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLSimpleUser.h"

@interface LLLike : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *voice;
@property (nonatomic, copy) NSString *distanceText;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSNumber *goodCount;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *nickname;

//@property (nonatomic, strong) NSMutableArray *goodlist;

@property (nonatomic, strong) LLSimpleUser *user;


@end
