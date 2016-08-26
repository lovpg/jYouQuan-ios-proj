//
//  LLCoverButtom.m
//  Olla
//
//  Created by between_ios on 14-10-31.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLCoverButtom.h"

@implementation LLCoverButtom

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
    self.layer.cornerRadius = 5;
}

@end
