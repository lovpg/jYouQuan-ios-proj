//
//  TMSegmentViewController.h
//  Olla
//
//  Created by Reco on 16/5/23.
//  Copyright © 2016年 xiaoran. All rights reserved.
//

#import "LLBaseViewController.h"

@protocol TMSegmentViewControllerDelegate <NSObject>

- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller;

- (void)btnResponse:(NSInteger)index;

@end

@interface TMSegmentViewController : UIViewController

@property (nonatomic, weak) id <TMSegmentViewControllerDelegate> delegate;

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong, readonly) NSMutableArray *titles;
@property (nonatomic, strong, readonly) NSMutableArray *childControllers;
@property (nonatomic, strong, readonly) NSMutableArray *btnImages;
@property (nonatomic, strong) UIFont  *menuItemFont;
@property (nonatomic, strong) UIColor *menuItemTitleColor;
@property (nonatomic, strong) UIColor *menuItemSelectedTitleColor;
@property (nonatomic, strong) UIColor *menuBackGroudColor;
@property (nonatomic, strong) UIColor *menuIndicatorColor;

- (id)initWithControllers:(NSArray *)controllers
             topBarHeight:(CGFloat)topBarHeight
                btnImages:(NSArray *)images
     parentViewController:(UIViewController *)parentViewController;

@end
