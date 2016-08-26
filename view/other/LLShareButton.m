//
//  LLShareButton.m
//  Olla
//
//  Created by null on 14-11-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLShareButton.h"

@implementation LLShareButton

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
    
    self.selectedBackgroundColor = RGB_HEX(0xF9F9F9);
}

@end
