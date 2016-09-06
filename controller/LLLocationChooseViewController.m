//
//  LLLocationChooseViewController.m
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLLocationChooseViewController.h"


#define LocationBackgroundViewWidth 100
#define LocationLblRectInset UIEdgeInsetsMake(5, 5, 20, 5)

@interface LLLocationChooseViewController ()

@end

@implementation LLLocationChooseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.center=self.view.center;
    [self.view addSubview:activity];
    [activity startAnimating];
    
    chooseButton.enabled = NO;
    locationManager = [[CLLocationManager alloc]init];
    BOOL enabled = [CLLocationManager locationServicesEnabled];
    if( !enabled || [CLLocationManager authorizationStatus] < 3 )
    {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [self setupView];
    [self startUploadLocation];
    
}

- (IBAction)backAction:(id)sender
{
  [self openURL:[NSURL URLWithString:@"." relativeToURL:self.url] animated:YES];
}



- (void)setupView{
    
    UIImageView *pin = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 17, 25)];
    pin.image = [UIImage imageNamed:@"share_location_pin"];
    _pinImageView = pin;
    pin.center = CGPointMake(20, -30);
    [self.view addSubview:pin];
    pin.alpha = 0;
    
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, LocationBackgroundViewWidth, 0)];
    [self.view addSubview:bg];
    bg.backgroundColor = [UIColor clearColor];
    _locationBgIV = bg;
    _locationBgIV.image = [[UIImage imageNamed:@"share_location_pin_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 15, 5)];
    
    
    UILabel *location = [[UILabel alloc] initWithFrame:bg.bounds];
    location.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [location setTextAlignment:NSTextAlignmentCenter];
    location.font = [UIFont systemFontOfSize:15];
    location.textColor = [UIColor whiteColor];
    location.backgroundColor = [UIColor clearColor];
    location.numberOfLines = 10;
    [bg addSubview:location];
    _locationLbl = location;
    
    
}

- (void)startUploadLocation
{

    if (![CLLocationManager locationServicesEnabled]||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied||[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        
        //todo
        NSString *message = @"无法获取位置信息";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] ;
        [alertView show];
        
        DDLogError(@"未获得授权使用位置或正在定位或没有定位信息");
        
    }else{
        
        _mapView.showsUserLocation = YES;
    }
    
}


- (IBAction)choosePositionClicked:(id)sender{
    
    if (!_currentLocation) {
        DDLogError(@"_currentLocation is nil");
        return;
    }
    
    if (![_locationLbl.text length]) {
        _locationLbl.text = @"location error";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LLLocationChooseNotification"
                                                        object:nil
                                                      userInfo:@{@"address": _locationLbl.text,
                                                                 @"location":_currentLocation}
     ];
    
    [self openURL:[NSURL URLWithString:@"." relativeToURL:self.url] animated:YES];
    
}




#pragma mark - mapview delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (hasUserLocation) {
        if (!regionFirstChange) {
            regionFirstChange = YES;
            return;
        }
        
        //MKCoordinateRegion newRegion = _mapView.region;
        CLLocationCoordinate2D coordinate = [mapView convertPoint:self.view.center toCoordinateFromView:self.view];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        _currentLocation = location;
        [self locationFrom:location];
        
        chooseButton.enabled = YES;
    }
}



- (void)locationFrom:(CLLocation *)location{
    
    __block NSMutableString *locationInfo = [[NSMutableString alloc] init] ;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks,NSError *error){
        
        if (!error && [placemarks count]>0) {
            CLPlacemark *place = [placemarks objectAtIndex:0];
            
            if (place.country) {
                [locationInfo appendString:place.country];
            }
            if (place.addressDictionary[@"State"]) {
                [locationInfo appendString:place.addressDictionary[@"State"]];
            }
            if (place.addressDictionary[@"Street"]) {
                [locationInfo appendString:place.addressDictionary[@"Street"]];
            }
            
            
            //locationInfo = [NSString stringWithFormat:@"%@ %@ %@",place.country,place.addressDictionary[@"State"],place.addressDictionary[@"Street"]];
            
        }else{
            
            //locationInfo = @"unkonwn";
            [locationInfo appendString:@"unkonwn"];
            
        }
        
        _locationLbl.text = locationInfo;
        CGSize locationSize = [locationInfo sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(LocationBackgroundViewWidth-LocationLblRectInset.left - LocationLblRectInset.right, 100)];
        _locationBgIV.frame = CGRectMake(
                                         self.view.center.x-LocationBackgroundViewWidth/2, _pinImageView.center.y - 15 - locationSize.height - LocationLblRectInset.top - LocationLblRectInset.bottom, LocationBackgroundViewWidth,
                                         locationSize.height+LocationLblRectInset.top + LocationLblRectInset.bottom);
        _locationLbl.frame = CGRectMake(
                                        LocationLblRectInset.left,LocationLblRectInset.top,LocationBackgroundViewWidth-LocationLblRectInset.left - LocationLblRectInset.right,locationSize.height);
    }];
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        static NSString *identifier = @"currentLocation";
        MKAnnotationView *pulsingView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(pulsingView == nil) {
            pulsingView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        pulsingView.canShowCallout = YES;
        
        return pulsingView;
    }
    
    return nil;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    
    if(userLocation.location==nil)
    {
        _mapView.showsUserLocation = NO;
        //NSLog(@"获取地理位置失败,未知错误");
        return;
    }
    
    MKCoordinateRegion region;
    region.center = [userLocation coordinate];
    region.span = MKCoordinateSpanMake(0.01, 0.01);
    [_mapView setRegion:region animated:YES];
    
    _currentLocation = userLocation.location;
    [self locationFrom:_currentLocation];
    chooseButton.enabled = YES;
    
    _locationBgIV.image = [[UIImage imageNamed:@"share_location_pin_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 15, 5)];
    _locationBgIV.alpha = 0.f;
    
    [UIView animateWithDuration:0.7 animations:^{
        
        _pinImageView.alpha = 1.f;
        _pinImageView.center = CGPointMake(self.view.center.x, self.view.center.y-_pinImageView.frame.size.height/2);
        
    } completion:^(BOOL finished){
        
        if (finished) {
            [UIView animateWithDuration:0.7f animations:^{
                _locationBgIV.alpha = 1.f;
            } completion:^(BOOL finished) {
                [activity stopAnimating];
            }];
        }
    }];
    
    hasUserLocation  = YES;
    _mapView.showsUserLocation = NO;
}



@end
