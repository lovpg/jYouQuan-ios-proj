//
//  LLRoundingCornersButton.m
//  Olla
//
//  Created by null on 14-11-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLRoundingCornersButton.h"

@implementation LLRoundingCornersButton

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self roundingCorners:self.rectCorner cornerRadius:self.cornerRadius];
}


@end
