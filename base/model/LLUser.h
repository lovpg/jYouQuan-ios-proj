//
//  LLUser.h
//  Olla
//
//  Created by nonstriater on 14-7-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLUser : OllaModel<NSCoding>

@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *avatar;
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *nickname;
@property(nonatomic,strong) NSString *birth;
@property(nonatomic,strong) NSString *gender;
@property(nonatomic,strong) NSString *region;
@property(nonatomic,strong) NSString *speaking;//speaking/native
@property(nonatomic,strong) NSString *learning;
@property(nonatomic,strong) NSString *interests;
@property(nonatomic,strong) NSString *qtlevel;
@property (nonatomic, strong) NSString *age;
@property(nonatomic,assign) BOOL follow;
@property(nonatomic,assign) BOOL fans;
@property(nonatomic,strong) NSString *cover;
@property(nonatomic,strong) NSString *followCount;
@property(nonatomic,strong) NSString *fansCount;
@property (nonatomic, strong) NSString *email;
@property(nonatomic,strong) NSString *points;
@property(nonatomic,strong) NSString *sign;
@property(nonatomic,strong) NSString *voice;//录音url
@property(nonatomic,strong) NSString *distanceText;//距离
@property(nonatomic,strong) NSString *location; //坐标
@property(nonatomic,strong) NSString *equipType;
@property (nonatomic) BOOL isRedPoint;

// 保存follow状态
@property (nonatomic, strong) NSString *followState;


- (NSString *)easeUserName;
- (NSString *)easePassword;

+ (NSArray *)myFriends;
+ (NSArray*)myFans;
@end
