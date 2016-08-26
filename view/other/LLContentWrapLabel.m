//
//  LLContentWrapLabel.m
//  Olla
//
//  Created by null on 14-9-30.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLContentWrapLabel.h"

@implementation LLContentWrapLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setText:(NSString *)text{
    
    [super setText:text];

    self.width = [text sizeWithFont:self.font constrainedSize:CGSizeMake(320, 320)].width;
    if (self.width>0.f) {
         [self setWidth:self.width+10.f];
    }
   
    
    if (self.width>200.f) {
        self.width = 200.f;
    }
}

@end


