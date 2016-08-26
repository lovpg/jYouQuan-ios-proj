//
//  LLLineView.m
//  Olla
//
//  Created by null on 14-10-28.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLLineView.h"

@implementation LLLineView


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
    self.height = 0.5f;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}



@end
