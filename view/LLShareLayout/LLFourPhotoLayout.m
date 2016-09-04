//
//  LLFourPhotoLayout.m
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLFourPhotoLayout.h"
#import "LLShareImageButton.h"
@implementation LLFourPhotoLayout

- (CGFloat)layoutHeight {
    return self.maxWidth;
}

// 2行
- (void)layout{

    NSUInteger photoCount = [self.photos count];
    CGFloat padding = 5.f;
    
    CGFloat width = self.maxWidth / 2;
    
    CGRect rect = CGRectZero;
    for (int i=0; i<photoCount; i++) {
        int x = padding*(i%2)+i%2*width;
        int y = (i/2)?(padding*2+width):padding;
        rect = CGRectMake(x, y, width,width);
        LLShareImageButton *imageView = [LLShareImageButton buttonWithType:UIButtonTypeCustom];
        imageView.frame = rect;
//        imageView.cornerRadius = 6.f;
         imageView.cornerRadius = 0.f;
        imageView.tag = i+1;
        [imageView setRemoteImageURL:self.photos[i]];
        [imageView addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageView];
    }
    
    self.width = [self layoutHeight];
    self.height = [self layoutHeight];
    
}

@end
