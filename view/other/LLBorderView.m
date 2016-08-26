//
//  LLBoardView.m
//  Olla
//
//  Created by null on 14-10-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBorderView.h"

@implementation LLBorderView


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitial];
    }
    return self;
}

- (void)awakeFromNib{
    [self commonInitial];
}

- (void)commonInitial{
    self.backgroundColor = RGB_HEX(0xF9F9F9);
    [self.layer setBorderWidth:1.f];
    [self.layer setCornerRadius:2.f];
}



@end
