//
//  LLPhotoLayout.m
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLPhotoLayout.h"
//#import "LLImageBrowserController.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "KZVideoPlayer.h"

@implementation LLPhotoLayout

@synthesize photos = _photos;

- (CGFloat)layoutHeight{
    return 0.f;
}

-(void)setPhotos:(NSArray *)photos{
    _photos = photos;
    [self layout];
}

// 这里做布局
- (void)layout{

}

- (CGRect)viewFrameAtIndex:(NSUInteger)index{
    return CGRectZero;
}

- (void)photoSelected:(id)sender{

    if ([sender isKindOfClass:UIButton.class]) {
        NSInteger index =[(UIView *)sender  tag];
        [self photoSelectedAtIndex:index-1];
    }
}

// 这里是点击时间处理
- (void)photoSelectedAtIndex:(NSInteger)index{
    
    //[[LLImageBrowserController sharedInstance] thumbsImages:self.photos selectAtIndex:index];
    
    if (self.isMovie)
    {
//        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
//        NSMutableArray *mjPhotos = [NSMutableArray array];
//        for (int i = 0; i < self.photos.count; i++)
//        {
//            UIView *subView = (i<6)?self.subviews[i]:nil;//最多显示6张图
//            MJPhoto *photo = [[MJPhoto alloc] init];
//            photo.url = [NSURL URLWithString:[LLAppHelper shareImageURLWithThumbString:self.photos[i]]];
//            photo.placeholder = [(UIButton *)subView image];
//            photo.startFrame = [[UIApplication sharedApplication].keyWindow convertRect:subView.frame fromView:subView.superview];
//            [mjPhotos addObject:photo];
//        }
//        browser.photos = mjPhotos;
//        browser.currentPhotoIndex = index;
//        [browser show];
        NSURL *videoPlayUrl = [NSURL URLWithString:self.videoUrl];
        KZVideoPlayer *player = [[KZVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) videoUrl:videoPlayUrl];
        //    [self.view addSubview:player];
        UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
        [keyWindow addSubview:player];
    
    }
    else
    {
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        NSMutableArray *mjPhotos = [NSMutableArray array];
        for (int i = 0; i < self.photos.count; i++)
        {
           UIView *subView = (i<6)?self.subviews[i]:nil;//最多显示6张图
           MJPhoto *photo = [[MJPhoto alloc] init];
           photo.url = [NSURL URLWithString:[LLAppHelper shareImageURLWithThumbString:self.photos[i]]];
           photo.placeholder = [(UIButton *)subView image];
           photo.startFrame = [[UIApplication sharedApplication].keyWindow convertRect:subView.frame fromView:subView.superview];
           [mjPhotos addObject:photo];
        }
        browser.photos = mjPhotos;
        browser.currentPhotoIndex = index;
        [browser show];
    }
    
}

@end


