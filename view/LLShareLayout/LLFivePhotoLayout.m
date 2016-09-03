//
//  LLFivePhotoLayout.m
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLFivePhotoLayout.h"
#import "LLShareImageButton.h"

@implementation LLFivePhotoLayout

- (CGFloat)layoutHeight{
//    return (self.maxWidth - 40) / 3 +  (self.maxWidth - 40) / 2;
    return self.maxWidth/3 + self.maxWidth/2;
}

//
- (void)layout{
    NSUInteger photoCount = [self.photos count];
    CGFloat padding = 5.f;
//    CGFloat sWidth = (self.maxWidth - 48) / 3;
//    CGFloat bWidth = (self.maxWidth - 44) / 2;
    CGFloat sWidth = self.maxWidth/ 3;
    CGFloat bWidth = self.maxWidth/ 2;
    CGFloat width = 0.f;
    
    CGRect rect=CGRectZero;
    for (int i=0; i<photoCount; i++) {
        width = (i<2)?bWidth:sWidth;
        int sum = (i<2)?2:3;
        int ii = (i<2)?i:i-2;
        int x = padding*(ii%sum)+ii%sum*width;
        int y = (i<2)?padding:padding*2+bWidth;
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
    
    self.height = [self layoutHeight];
    self.width = self.maxWidth;
    
}

@end
