//
//  LLOnePhotoLayout.m
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLOnePhotoLayout.h"
#import "LLShareImageButton.h"

// 固定0.4压缩
@implementation LLOnePhotoLayout

//图片还要下载，如何确定高度
- (CGFloat)layoutHeight
{
    float width = self.maxWidth;
    return width;
}

- (void)layout
{
    
    float width = [self layoutHeight];
    
    LLShareImageButton *imageView = [LLShareImageButton buttonWithType:UIButtonTypeCustom];

    imageView.placeholder = @"headphoto_default_280x280";
    imageView.frame = CGRectMake(0, 0, width, width);
//    imageView.cornerRadius = 6.f;
    imageView.cornerRadius = 0.f;
    imageView.tag = 1;
    [self addSubview:imageView];
    self.width = width;
    self.height = width;
    
    if ([self.photos count])
    {
        [imageView setRemoteImageURL:self.photos[0]];
        [imageView addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)removeFromSuperview {
    for (LLShareImageButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button sd_cancelImageLoadForState:UIControlStateNormal];
        }
    }
    [super removeFromSuperview];
}

@end


