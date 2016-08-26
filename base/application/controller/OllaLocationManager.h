//
//  OllaLocationManager.h
//  Olla
//
//  Created by null on 14-9-22.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationCompleteBlock)(NSString *location,NSError *error);

@interface OllaLocationManager : NSObject

@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) LocationCompleteBlock completeBlock;

//获取经纬度信息
- (void)startLocationCompleteBlock:(void (^)(NSString *location,NSError *error))completion;


@end
