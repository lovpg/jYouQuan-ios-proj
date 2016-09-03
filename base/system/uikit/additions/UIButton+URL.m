//
//  UIButton+URL.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//


#import "UIButton+URL.h"
#import "UIButton+WebCache.h"

static NSString *defaultPlaceholderImage = @"headphoto_default_128";
const static void *placeholderKey = &placeholderKey;
const static void *placeholderDisableKey = &placeholderDisableKey;

@implementation UIButton (URL)

@dynamic remoteImageURL;
@dynamic remoteBackgroundImageURL;
@dynamic image;
@dynamic placeholderDisable;
@dynamic selectedBackgroundColor;

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor{
    [self setBackgroundImage:[UIImage imageWithColor:selectedBackgroundColor] forState:UIControlStateHighlighted];
}


- (NSString *)placeholder{
    NSString *ph = objc_getAssociatedObject(self, placeholderKey);
    return ph;
}

- (void)setPlaceholder:(NSString *)placeholder{
    objc_setAssociatedObject(self, placeholderKey, placeholder, OBJC_ASSOCIATION_COPY);
}


- (void)setImage:(UIImage *)image{
    
    [self setImage:image forState:UIControlStateNormal];
}

- (BOOL)placeholderDisable{
    return [objc_getAssociatedObject(self, placeholderDisableKey) boolValue];
}

- (void)setPlaceholderDisable:(BOOL)placeholderDisable{
    objc_setAssociatedObject(self, placeholderDisableKey, @(placeholderDisable), OBJC_ASSOCIATION_ASSIGN);
}
-(void)setRemoteImageURL:(NSString *)remoteImageURL{
    
    if ([self.placeholder length]==0) {
        self.placeholder = defaultPlaceholderImage;
    }
    
    if (self.placeholderDisable) {
        self.placeholder = nil;
    }
    
    if(![remoteImageURL isString]){
        DDLogError(@"非法的url:%@",remoteImageURL);
        [self setImage:[UIImage imageNamed:self.placeholder] forState:UIControlStateNormal];
        return;
    }
   
     __weak UIButton *wself = self;

    [self sd_setBackgroundImageWithURL: [NSURL URLWithString:remoteImageURL]
                              forState:UIControlStateNormal
                      placeholderImage:[UIImage imageNamed:self.placeholder]
                               options:SDWebImageAllowInvalidSSLCertificates|SDWebImageRetryFailed
                             completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL)
    {

        
        
//        float width = image.size.width;
//        float height = image.size.height;
//        float _width = wself.frame.size.width;
//        float _height = wself.frame.size.height;
//        NSLog(@"%0.2f,%0.2f,%0.2f,%0.2f", width, height,_width,_height);
//        if( _width > 280 )
//        {
//            float subWidth = width - _width;
//            float subHeight = height - _height;
//            if(subWidth > subHeight)
//            {
//                float tHeight = _width * (height/width);
//                wself.frame = CGRectMake(0, 0, _width, tHeight);
//            }
//            else
//            {
//                float tWidth = _height * (width/height);
//                wself.frame = CGRectMake(0, 0, tWidth, _height);
//            }
//        }
        
        dispatch_main_sync_safe(^{
            __strong UIButton *sself = wself;
            if (!sself) return;
            if (error) {
                DDLogError(@"图片(url=%@)下载失败：%@",remoteImageURL,error);
                [sself setImage:[UIImage imageNamed:@"PhotoDownloadfailed"] forState:UIControlStateNormal];
            }
        });
//        
    }];
    
     
}


-(void)setRemoteBackgroundImageURL:(NSString *)remoteBackgroundImageURL{
    if (![remoteBackgroundImageURL isKindOfClass:[NSString class]]) {
        return;
    }
    [self sd_setBackgroundImageWithURL:[NSURL URLWithString:remoteBackgroundImageURL] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates];
}



@end
