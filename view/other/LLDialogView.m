//
//  LLDialogView.m
//  Olla
//
//  Created by null on 14-10-17.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLDialogView.h"

@implementation LLDialogView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)show:(BOOL)animated{

    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor clearColor];
    }
    [self setBackgroundColor:self.backgroundColor];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.center = keyWindow.center;
    
    if (self.backgroundImageView) {
        self.backgroundImageView.frame = self.bounds;
        [self addSubview:self.backgroundImageView];
    }
    
    if (self.customView) {
        self.frame = self.customView.bounds;
        [self addSubview:self.customView];
    }

    maskButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [maskButton addTarget:self action:@selector(maskClicked:) forControlEvents:UIControlEventTouchUpInside];
    maskButton.frame = keyWindow.bounds;
    maskButton.backgroundColor = [UIColor blackColor];
    maskButton.alpha = 0.2f;
    [maskButton addSubview:self];
    [keyWindow addSubview:maskButton];
    
    if (animated) {
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.4];
    }
    maskButton.alpha = 1.f;
    
    if (animated) {
        [UIView commitAnimations];
    }
    
}

- (void)maskClicked:(id)sender{

    [self dismiss];
}

- (void)dismiss{

    [self removeFromSuperview];
    [maskButton removeFromSuperview];
}


@end

