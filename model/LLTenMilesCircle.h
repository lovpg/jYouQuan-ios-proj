//
//  LLTenMilesCircle.h
//  iDleChat
//
//  Created by Reco on 16/3/14.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLTenMilesCircle : OllaModel<NSCoding>


@property(nonatomic,strong) NSString *tmcname;
@property(nonatomic,strong) NSString *tmcid;
@property(nonatomic,strong) NSString *tags;
@property(nonatomic,strong) NSString *category;
@property(nonatomic,strong) NSString *city;
@property(nonatomic,strong) NSString *business;
@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *lat;
@property(nonatomic,strong) NSString *lng;
@property(nonatomic,strong) NSString *location;
@property(nonatomic,strong) NSString *address;
@property(nonatomic,strong) NSString *open;
@property(nonatomic,strong) NSString *sign;
@property(nonatomic,strong) NSString *distance;
@property(nonatomic,strong) NSString *follow;
@property(nonatomic,strong) NSString *avator;
@property(nonatomic,strong) NSString *token;

@end
