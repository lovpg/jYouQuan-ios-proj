//
//  UIButton+OllaStyle.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-2.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "UIButton+OllaStyle.h"

@implementation UIButton (OllaStyle)

-(NSString *)text{

    return [self titleForState:UIControlStateNormal];
}

- (void)setText:(NSString *)text{
    [self setTitle:text forState:UIControlStateNormal];
}

- (UIColor *)textColor{
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)textColor{
    [self setTitleColor:textColor forState:UIControlStateNormal];
}

-(UIImage *)image{
    return [self imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image{

    [self setImage:image forState:UIControlStateNormal];
}


@end
