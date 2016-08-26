//
//  OllaBackButton.m
//  Olla
//
//  Created by null on 14-10-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaBackButton.h"

@implementation OllaBackButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInitial];
    }
    return self;
}

- (void)awakeFromNib{

    [self commonInitial];
}


- (void)commonInitial{
    self.actionName = @"url";
    self.userInfo = @".";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
