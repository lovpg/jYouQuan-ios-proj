//
//  LLLocationChooseViewController.h
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLBaseViewController.h"
#import <MapKit/MapKit.h>

@interface LLLocationChooseViewController : LLBaseViewController
{
    IBOutlet MKMapView    *_mapView;
    IBOutlet UIButton *chooseButton;

    UILabel      *_locationLbl;
    UIImageView  *_locationBgIV;
    UIImageView  *_pinImageView;
    UIActivityIndicatorView *activity;
    CLLocationManager  *locationManager;

    CLLocation      *_currentLocation;
    BOOL            hasUserLocation;
    BOOL            regionFirstChange;
}

- (IBAction)choosePositionClicked:(id)sender;

@end
