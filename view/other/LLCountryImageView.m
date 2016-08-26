//
//  LLCountryImageView.m
//  Olla
//
//  Created by null on 14-9-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLCountryImageView.h"

@implementation LLCountryImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setRegion:(NSString *)region{
    
    if (_region != region) {
        _region = region;
        self.image = [UIImage imageNamed:[LLAppHelper countryIconFromString:region]];
    }
}


@end
