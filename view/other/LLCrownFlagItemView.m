//
//  LLCrownFlagItemView.m
//  Olla
//
//  Created by Pat on 15/4/24.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLCrownFlagItemView.h"

@interface LLCrownFlagItemView () {
    UIImageView *_imageView;
    UILabel *_regionLabel;
    UILabel *_countLabel;
}

@end

@implementation LLCrownFlagItemView

- (instancetype)init
{
    self = [super init];
    if (self) {

        _imageView = [[UIImageView alloc] init];
        
        _regionLabel = [[UILabel alloc] init];
        _regionLabel.font = [UIFont systemFontOfSize:13];
        _regionLabel.textColor = [UIColor blackColor];
        _regionLabel.textAlignment = NSTextAlignmentCenter;
        _regionLabel.backgroundColor = [UIColor clearColor];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:11];
        _countLabel.textColor = [UIColor lightGrayColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_imageView];
        [self addSubview:_regionLabel];
        [self addSubview:_countLabel];

    }
    return self;
}

- (void)setItem:(LLCrownFlagItem *)item {
    _item = item;
    _imageView.image = item.flagImage;
    _regionLabel.text = item.region;
    _countLabel.text = item.count;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _regionLabel.frame = CGRectMake(5, 0, self.width - 10, 20);
    _regionLabel.center = CGPointMake(self.width / 2, self.height / 2);
    
    _imageView.frame = CGRectMake(self.width / 2 - 10, _regionLabel.top - 20, 20, 20);
    
    _countLabel.frame = CGRectMake(5, _regionLabel.bottom, self.width - 10, 20);
    
}

@end
