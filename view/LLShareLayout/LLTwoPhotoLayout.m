//
//  LLTwoPhotoLayout.m
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLTwoPhotoLayout.h"
#import "LLShareImageButton.h"

@implementation LLTwoPhotoLayout

- (CGFloat)layoutHeight
{
    NSUInteger photoCount = [self.photos count];
    return (self.maxWidth - 44) / photoCount;
}

- (void)layout{

    NSUInteger photoCount = [self.photos count];
    CGFloat padding = 5;
   // float width = (self.maxWidth - (photoCount == 2 ? 44 : 48)) / photoCount;
    float width = (self.maxWidth - (photoCount == 2 ? 44 : 48)) / photoCount;
    for (int i=0; i<photoCount; i++)
    {
        LLShareImageButton *imageView = [LLShareImageButton buttonWithType:UIButtonTypeCustom];
        imageView.frame = CGRectMake(padding*(i)+i*width, 0, width, width);
        imageView.cornerRadius = 6.f;
        imageView.tag = i+1;
        [imageView setRemoteImageURL:self.photos[i]];
        [imageView addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageView];
    }
    
    self.width = self.maxWidth - 40;
    self.height = width;
}


@end

