//
//  LLEaseNotificationObject.h
//  Olla
//
//  Created by Pat on 15/11/11.
//  Copyright © 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

// 自定义环信扩展通知对象

@interface LLEaseNotificationObject : NSObject

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *userAvator;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *region;

@property (nonatomic, strong) NSString *oUserAvator;
@property (nonatomic, strong) NSString *oNickName;
@property (nonatomic, strong) NSString *oGender;
@property (nonatomic, strong) NSString *oRegion;

@property (nonatomic, strong) NSString *cUserAvator;
@property (nonatomic, strong) NSString *cNickName;
@property (nonatomic, strong) NSString *cGender;
@property (nonatomic, strong) NSString *cRegion;

@property (nonatomic, strong) NSString *barName;
@property (nonatomic, strong) NSString *barAvator;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *tags;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, assign) long memberCount;
@property (nonatomic, assign) long postCount;

@property (nonatomic, assign) long uid;
@property (nonatomic, assign) long ouid;
@property (nonatomic, assign) long commentedUid;
@property (nonatomic, assign) long bid;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *shareId;


@end
