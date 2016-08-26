//
//  UIImageView+OllaStyle.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "UIImageView+OllaStyle.h"
#import "UIView+style.h"

@implementation UIImageView (OllaStyle)

@dynamic imageIcon;

- (void)setCornerRadius:(CGFloat)cornerRadius{
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
}

- (void)setImageIcon:(NSString *)imageIcon{

    [self setImage:[UIImage imageNamed:imageIcon]];
}



@end
