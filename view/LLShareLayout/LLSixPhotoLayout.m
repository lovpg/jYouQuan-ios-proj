//
//  LLSixPhotoLayout.m
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLSixPhotoLayout.h"
#import "LLShareImageButton.h"
@implementation LLSixPhotoLayout

- (CGFloat)layoutHeight {
//    return (self.maxWidth - 40) * 0.75;
    return self.maxWidth*0.75;
}

- (void)layout{
    
    NSUInteger photoCount = [self.photos count];
    CGFloat padding = 5.f;
//    CGFloat width = (self.maxWidth - 48) / 3;
    CGFloat width = self.maxWidth / 3;
    CGRect rect=CGRectZero;
    for (int i=0; i<photoCount; i++) {
        if(i==6) break;
        int x = (i%3)*width+(i%3)*padding;
        int y = (i/3)*width+(i/3+1)*padding;
        rect = CGRectMake(x, y, width,width);
        LLShareImageButton *imageView = [LLShareImageButton buttonWithType:UIButtonTypeCustom];
        imageView.frame = rect;
//        imageView.cornerRadius = 6.f;
        imageView.cornerRadius = 1.f;
        imageView.tag = i+1;
        [imageView setRemoteImageURL:self.photos[i]];
        [imageView addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageView];
    }
    
    self.height = [self layoutHeight];
    self.width = self.maxWidth;
    
}

@end


