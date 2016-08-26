//
//  OllaLocationManager.m
//  Olla
//
//  Created by null on 14-9-22.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaLocationManager.h"

@interface OllaLocationManager ()<CLLocationManagerDelegate>{

    BOOL first;// avoid didupdateLocations: call multi times;
}

@end

@implementation OllaLocationManager

- (id)init{
    
    if (self = [super init]) {
    
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 50.f;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
             [_locationManager requestWhenInUseAuthorization];
        }
#endif
        
        first = YES;
    }
    
    return self;
}

- (void)startLocationCompleteBlock:(void (^)(NSString *location,NSError *error))completion{

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    if (![CLLocationManager locationServicesEnabled]) {
        //TODO9:提示引导用户开启地理位置授权
        NSError *error = [self locationAuthNotAllowedError];
        completion(nil,error);
        return;
    }
#else
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        NSError *error = [self locationAuthNotAllowedError];
        completion(nil,error);
        return;
    }
#endif
    
    self.completeBlock = completion;
    [_locationManager startUpdatingLocation];
    first = YES;
}

- (NSError *)locationAuthNotAllowedError{
    
    NSString *message = @"No location fetch,you can not get our service";
    NSError *error = [[NSError alloc] initWithDomain:@"com.olla.error.NoLocationFetchException" code:-1 userInfo:@{@"message":message}];
    
    return error;
}

// ////////// location delegate // //////////

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    [_locationManager stopUpdatingLocation];
    self.completeBlock(nil,error);
    first= YES;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if ([locations count]==0) {
        //TODO: 获取位置信息失败提醒
        DDLogError(@"no Location get");
        [_locationManager stopUpdatingLocation];
        NSError *error = [[NSError alloc] initWithDomain:@"LocationException" code:-1 userInfo:@{@"message":@"no Location get"}];
        self.completeBlock(nil,error);
        first = YES;
        return ;
    }
    
    //获取到地址后才开始请求数据,注意，这里的didUpdateLocations会被call多次，导致数据下载多次！！
    
    CLLocation *currentLocation = [locations lastObject];
    if (first) {
        [self updateLocationSuccess:currentLocation];
        first= NO;
        return;
    }
}

- (void)updateLocationSuccess:(CLLocation *)location{
    
    NSString *loc = [NSString stringWithFormat:@"%@,%@",[NSNumber numberWithDouble:location.coordinate.latitude],[NSNumber numberWithDouble:location.coordinate.longitude]];
    DDLogInfo(@"获取位置信息loc=%@",loc);
    self.completeBlock(loc,nil);
    
    [_locationManager stopUpdatingLocation];//关闭以节省电量

}


@end



