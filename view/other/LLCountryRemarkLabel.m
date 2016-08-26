//
//  LLCountryLable.m
//  Olla
//
//  Created by Wang Cheng on 14-10-31.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLCountryRemarkLabel.h"

@implementation LLCountryRemarkLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonIntial];
    }
    return self;
}

- (void)awakeFromNib{
    [self commonIntial];
}

// 初始化
- (void)commonIntial{
    
    self.backgroundView= [[UIView alloc ]initWithFrame:self.bounds];
    [self.backgroundView setBackgroundColor:RGB_HEX(0xFFFFFF)];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.backgroundView setAlpha:0.3];
    [self addSubview:self.backgroundView];
    [self setClipsToBounds:YES];
    
}








@end
