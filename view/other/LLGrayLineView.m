//
//  LLLineView2.m
//  Olla
//
//  Created by jieyuan on 14/11/4.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLGrayLineView.h"

@implementation LLGrayLineView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    self.backgroundColor = RGB_HEX(0xDCDCDC);
    self.height = 0.5f;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}



@end
