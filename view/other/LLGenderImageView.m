//
//  LLGenderImageView.m
//  Olla
//
//  Created by null on 14-9-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLGenderImageView.h"

@implementation LLGenderImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setGender:(NSString *)gender{

//    _gender = gender;
    _gender = [gender lowercaseString];
    
    self.image = [UIImage imageNamed:[LLAppHelper genderIconFromString:_gender]];
    
}


@end
