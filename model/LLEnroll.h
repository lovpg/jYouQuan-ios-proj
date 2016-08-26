//
//  LLEnroll.h
//  iDleChat
//
//  Created by Reco on 16/3/3.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLSimpleUser.h"

@interface LLEnroll : NSObject


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
@property (nonatomic, copy) NSString *username;

//@property (nonatomic, strong) NSMutableArray *goodlist;

@property (nonatomic, strong) LLSimpleUser *user;


@end
