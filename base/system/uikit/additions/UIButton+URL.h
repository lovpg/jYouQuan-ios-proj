//
//  UIButton+URL.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIButton (URL)

@property(nonatomic,strong) NSString *placeholder;
@property(nonatomic,strong) NSString *remoteImageURL;
@property(nonatomic,strong) NSString *remoteBackgroundImageURL;
@property(nonatomic,assign) BOOL placeholderDisable;

@property(nonatomic,strong) UIImage *image;

@property(nonatomic,strong) UIColor *selectedBackgroundColor;


@end
