//
//  FaceCollectionViewCell.m
//  Olla
//
//  Created by Pat on 15/3/25.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "FaceCollectionViewCell.h"

@interface FaceCollectionViewCell () {
}

@end

@implementation FaceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:30.0];
        
        [self addSubview:_button];
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    _button.frame = self.bounds;
}

@end
