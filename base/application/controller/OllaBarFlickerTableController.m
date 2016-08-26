//
//  OllaBarFlickerTableController.m
//  Olla
//
//  Created by null on 15-1-8.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "OllaBarFlickerTableController.h"

@interface OllaBarFlickerTableController (){
    CGFloat lastContentOffset;
}

@end

@implementation OllaBarFlickerTableController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.flicker = NO;
    }
    return self;
}

- (void)barHidden:(BOOL)hidden{
    
    if (![self.delegate isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    UIViewController *vc = (UIViewController *)self.delegate;
    [vc.navigationController setNavigationBarHidden:hidden animated:YES];
    [vc.tabBarController setTabBarHidden:hidden animated:YES];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (!self.flicker) {
        return;
    }
    
    if (!scrollView.isTracking) {
        return;
    }
    
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    
    if (currentOffsetY-lastContentOffset>5) {//up
        [self barHidden:YES];
    }
    
    if (currentOffsetY-lastContentOffset<-5){//down
        [self barHidden:NO];
    }
    
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (self.flicker) {
        [self barHidden:YES];
    }
    
    return YES;
}




@end
