//
//  LLImageBrowserController.m
//  Olla
//
//  Created by nonstriater on 14-8-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLImageBrowserController.h"
#import "MJPhotoBrowser.h"

@interface LLImageBrowserController (){
    OllaImageBrowserController *controller;//MWPhotoBrowser
    //MJPhotoBrowser *controller;
}
@end

@implementation LLImageBrowserController

+ (id)sharedInstance{
    
    static LLImageBrowserController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance= [[LLImageBrowserController alloc] init];
    });
    return instance;
    
}

- (id)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    controller = [[OllaImageBrowserController alloc] init];
    //controller = [[MJPhotoBrowser alloc] init];
    return self;
}

- (void)thumbsImages:(NSArray *)images selectAtIndex:(NSInteger)index{
    
    NSMutableArray *thumbImages = [NSMutableArray array];
    for (NSString *thumbImage in images) {
        [thumbImages addObject:[MWPhoto photoWithURL:[NSURL URLWithString:thumbImage]]];
    }
    controller.thumbImages = thumbImages;
    
    NSMutableArray *originImages = [NSMutableArray array];//item MWPhoto
    for (NSString *thumbImage in images) {
        [originImages addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[LLAppHelper shareImageURLWithThumbString:thumbImage]]]];
    }
    controller.images = originImages;
    
    
    if (self.viewController) {
        [self.viewController presentViewController:controller animated:NO completion:^{
            controller.currentIndex = index;
        }];
    }

}




@end
