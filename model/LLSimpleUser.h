//
//  LLSimpleUser.h
//  Olla
//
//  Created by null on 14-9-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLSimpleUser : OllaModel<NSCoding>

@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *avatar;
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *nickname;
@property(nonatomic,strong) NSString *remark;//备注
@property(nonatomic,strong) NSString *gender;
@property(nonatomic,strong) NSString *region;
@property(nonatomic,strong) NSString *sign;
@property(nonatomic,strong) NSString *voice;
@property(nonatomic,strong) NSString *distanceText;//距离
@property(nonatomic,strong) NSString *location; //坐标
@property(nonatomic,strong) NSString *qtlevel;  // 评分
@property(nonatomic,strong) NSString *age;
@property(nonatomic,strong) NSString *hide;
@property(nonatomic,strong) NSString *speaking;//speaking/native
@property(nonatomic,strong) NSString *learning;
@property(nonatomic,strong) NSNumber *points;
@property(nonatomic,strong) NSString *equipType;
+ (LLSimpleUser *)random;// 测试用
- (NSString *)easeUserName;
- (NSString *)easePassword;

@end


/*
 user =     {
 avatar = "https://olla.laopao.com/image.do?f=/user/avatar/a05bb3ceca154d78bab4f373a25bb4e9.jpg";
 country = Andorra;
 distanceText = "<null>";
 gender = other;
 location = "<null>";
 nickname = yyyy;
 sign = "";
 uid = 121135;
 };
 },
 
 */
