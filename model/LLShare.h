//
//  LLShare.h
//  Olla
//
//  Created by nonstriater on 14/8/23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLSimpleUser.h"
#import "LLThirdCollection.h"
//#import "LLGroupBar.h"

static NSString *LLShareTextURLClickEvent = @"LLShareTextURLClickEvent";
static NSString *LLShareTextPhoneNumberClickEvent = @"LLShareTextPhoneNumberClickEvent";

@interface LLShare : OllaModel<NSCoding>

@property(nonatomic,strong) NSString *shareId;
@property(nonatomic,strong) NSString *content;
@property(nonatomic,assign) double posttime;
@property(nonatomic,assign) double lat;
@property(nonatomic,assign) double lng;
@property(nonatomic,strong) NSString *cposttime;
@property(nonatomic,strong) NSArray *imageList;
@property(nonatomic,strong) NSString *tags;
@property(nonatomic,strong) NSString *address;
@property(nonatomic,strong) NSString *location;
@property(nonatomic,assign) int enrollCount;
@property(nonatomic,assign) int commentCount;
@property(nonatomic,assign) int goodCount;
@property(nonatomic,assign) BOOL good; //是否点赞
@property(nonatomic,assign) BOOL favorite;  // 是否收藏
@property(nonatomic,strong) LLSimpleUser *user;
@property(nonatomic,assign) BOOL top; //是否置顶
@property(nonatomic,strong) LLThirdCollection *collection;
//@property(nonatomic,strong) LLGroupBar *bar;

@property(nonatomic,strong) NSString *vedioUrl;

- (NSString *)timeString;

@end


/**
 
   = "";
 commentCount = 3;
 content = hi;
 good = 0;
 goodCount = 1;
 imageList =     (
 "https://olla.laopao.com/image.do?f=/share/5c35f2c977ad4426a9e7ca713aab5691.jpg"
 );
 location = "";
 posttime = 1410078017000;
 shareId = fe2f4efe393c47a08b05dac5a0a24704;
 uid = 121135;
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







