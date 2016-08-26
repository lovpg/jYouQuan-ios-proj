//
//  LLBadgeNumberView.m
//  Olla
//
//  Created by null on 14-10-28.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBadgeNumberView.h"

@implementation LLBadgeNumberView

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
    self.backgroundColor = RGB_HEX(0xFF0000);
    self.cornerRadius = CGRectGetWidth(self.bounds)/2;
}

// prevent background disappear when custom tableviewcell selected!
//http://stackoverflow.com/questions/7053340/why-do-all-backgrounds-disappear-on-uitableviewcell-select
- (void)setHighlighted:(BOOL)highlighted{
    self.backgroundColor = RGB_HEX(0xFF0000);
}


@end
