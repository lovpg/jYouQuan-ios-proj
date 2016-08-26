//
//  LLPhotoLayoutManager.m
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLPhotoLayoutManager.h"
#import "LLOnePhotoLayout.h"
#import "LLTwoPhotoLayout.h"
#import "LLFourPhotoLayout.h"
#import "LLFivePhotoLayout.h"
#import "LLSixPhotoLayout.h"


#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
@implementation LLPhotoLayoutManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.maxWidth = ScreenWidth;
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos{
    
    LLPhotoLayout *layout = nil;
    NSUInteger count = [photos count];
    if (count==1)
    {
        layout = [[LLOnePhotoLayout alloc] initWithFrame:CGRectZero];
    }
    else if(count==2||count==3)
    {
        layout = [[LLTwoPhotoLayout alloc] initWithFrame:CGRectZero];
    }
    else if(count==4)
    {
        layout = [[LLFourPhotoLayout alloc] initWithFrame:CGRectZero];
    }
    else if(count==5)
    {
        layout = [[LLFivePhotoLayout alloc] initWithFrame:CGRectZero];
    }
    else if(count>=6)
    {// 最多展示6张
        layout = [[LLSixPhotoLayout alloc] initWithFrame:CGRectZero];
    }
    layout.maxWidth = self.maxWidth;
    layout.photos = photos;
    
    _photoLayout = layout;
    
}


@end
