//
//  TMSegmentViewController.m
//  Olla
//
//  Created by Reco on 16/5/23.
//  Copyright © 2016年 xiaoran. All rights reserved.
//

#import "TMSegmentViewController.h"
#import "TMScrollMenuView.h"


static const CGFloat kYSLScrollMenuViewHeight = 40;

@interface TMSegmentViewController () <UIScrollViewDelegate, TMScrollMenuViewDelegate>

@property (nonatomic, assign) CGFloat topBarHeight;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) TMScrollMenuView *menuView;

@end

@implementation TMSegmentViewController

- (id)initWithControllers:(NSArray *)controllers
             topBarHeight:(CGFloat)topBarHeight
                btnImages:(NSArray *)images
     parentViewController:(UIViewController *)parentViewController
{
    self = [super init];
    if (self)
    {
        
        [parentViewController addChildViewController:self];
        [self didMoveToParentViewController:parentViewController];
        _topBarHeight = topBarHeight;
        _titles = [[NSMutableArray alloc] init];
        _btnImages = [[NSMutableArray alloc] init];
        _childControllers = [[NSMutableArray alloc] init];
        NSMutableArray *cc = [NSMutableArray array];
        for( id controller in controllers )
        {
            LLBaseNavigationController *nav  = (LLBaseNavigationController *)controller;
            [nav loadURL:nav.url basePath:@"/" animated:YES];
            [cc addObject:nav.childViewControllers.lastObject];
        }
        _childControllers = [cc mutableCopy];
        
        NSMutableArray *titles = [NSMutableArray array];
        for (UIViewController *vc in controllers)
        {
            [titles addObject:[vc valueForKey:@"title"]];
        }
        _titles = [titles mutableCopy];
        NSMutableArray *tmpImages = [NSMutableArray array];
        for( NSString *imageStr in images)
        {
            [tmpImages addObject:imageStr];
        }
        _btnImages = [images mutableCopy];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setupViews
    UIView *viewCover = [[UIView alloc]init];
    [self.view addSubview:viewCover];
    self.currentIndex = 0;
    // ContentScrollview setup
    _contentScrollView = [[UIScrollView alloc]init];
    _contentScrollView.frame = CGRectMake(0,_topBarHeight + kYSLScrollMenuViewHeight, self.view.frame.size.width, self.view.frame.size.height - (_topBarHeight + kYSLScrollMenuViewHeight));
    _contentScrollView.backgroundColor = [UIColor clearColor];
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.scrollsToTop = NO;
    [self.view addSubview:_contentScrollView];
    _contentScrollView.contentSize = CGSizeMake(_contentScrollView.frame.size.width * self.childControllers.count, _contentScrollView.frame.size.height);
    
    // ContentViewController setup
    for (int i = 0; i < self.childControllers.count; i++)
    {
        id obj = [self.childControllers objectAtIndex:i];
        if ([obj isKindOfClass:[UIViewController class]])
        {
            UIViewController *controller = (UIViewController*)obj;
            CGFloat scrollWidth = _contentScrollView.frame.size.width;
            CGFloat scrollHeght = _contentScrollView.frame.size.height;
            controller.view.frame = CGRectMake(i * scrollWidth, 0, scrollWidth, scrollHeght);
            [_contentScrollView addSubview:controller.view];
        }
    }
    // meunView
    _menuView = [[TMScrollMenuView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, (_topBarHeight + kYSLScrollMenuViewHeight))];
    _menuView.backgroundColor = self.menuBackGroudColor;
    _menuView.delegate = self;
    _menuView.viewbackgroudColor =  [UIColor colorWithPatternImage: [UIImage imageNamed:@"plaza_top_bg@2x"]];
    _menuView.itemfont = self.menuItemFont;
    _menuView.itemTitleColor = self.menuItemTitleColor;
    _menuView.itemfont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    _menuView.itemIndicatorColor = self.menuIndicatorColor;
    _menuView.scrollView.scrollsToTop = NO;
    [_menuView setItemTitleArray:self.titles];
    _menuView.helpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     _menuView.helpButton.frame = CGRectMake(_menuView.frame.size.width - kYSLScrollMenuViewHeight, _topBarHeight + (kYSLScrollMenuViewHeight - 32)/2 + 3 , 28, 28);
    [ _menuView.helpButton setBackgroundImage: [UIImage imageNamed:[_btnImages objectAtIndex:self.currentIndex]]  forState:UIControlStateNormal];
    

    [ _menuView.helpButton addTarget:self action:@selector(rightBtnResponse:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [_menuView addSubview: _menuView.helpButton];
    [self.view addSubview:_menuView];
    [_menuView setShadowView];
    [self scrollMenuViewSelectedIndex:0];
}

- (void)rightBtnResponse:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(btnResponse:)])
    {
        [self.delegate btnResponse:self.currentIndex];
    }
}

#pragma mark -- private

- (void)setChildViewControllerWithCurrentIndex:(NSInteger)currentIndex
{
    for (int i = 0; i < self.childControllers.count; i++) {
        id obj = self.childControllers[i];
        if ([obj isKindOfClass:[UIViewController class]]) {
            UIViewController *controller = (UIViewController*)obj;
            if (i == currentIndex) {
                [controller willMoveToParentViewController:self];
                [self addChildViewController:controller];
                [controller didMoveToParentViewController:self];
            } else {
                [controller willMoveToParentViewController:self];
                [controller removeFromParentViewController];
                [controller didMoveToParentViewController:self];
            }
        }
    }
}
#pragma mark -- YSLScrollMenuView Delegate

- (void)scrollMenuViewSelectedIndex:(NSInteger)index
{
    [_contentScrollView setContentOffset:CGPointMake(index * _contentScrollView.frame.size.width, 0.) animated:YES];
    
    // item color
    [_menuView setItemTextColor:self.menuItemTitleColor
           seletedItemTextColor:self.menuItemSelectedTitleColor
                   currentIndex:index];
    
    [self setChildViewControllerWithCurrentIndex:index];
    
    if (index == self.currentIndex) { return; }
    self.currentIndex = index;

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(containerViewItemIndex:currentController:)])
    {
        [self.delegate containerViewItemIndex:self.currentIndex currentController:_childControllers[self.currentIndex]];
    }
}

#pragma mark -- ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat oldPointX = self.currentIndex * scrollView.frame.size.width;
    CGFloat ratio = (scrollView.contentOffset.x - oldPointX) / scrollView.frame.size.width;
    
    BOOL isToNextItem = (_contentScrollView.contentOffset.x > oldPointX);
    NSInteger targetIndex = (isToNextItem) ? self.currentIndex + 1 : self.currentIndex - 1;
    
    CGFloat nextItemOffsetX = 1.0f;
    CGFloat currentItemOffsetX = 1.0f;
    
    nextItemOffsetX = (_menuView.scrollView.contentSize.width - _menuView.scrollView.frame.size.width) * targetIndex / (_menuView.itemViewArray.count - 1);
    currentItemOffsetX = (_menuView.scrollView.contentSize.width - _menuView.scrollView.frame.size.width) * self.currentIndex / (_menuView.itemViewArray.count - 1);
    
    if (targetIndex >= 0 && targetIndex < self.childControllers.count) {
        // MenuView Move
        CGFloat indicatorUpdateRatio = ratio;
        if (isToNextItem) {
            
            CGPoint offset = _menuView.scrollView.contentOffset;
            offset.x = (nextItemOffsetX - currentItemOffsetX) * ratio + currentItemOffsetX;
            [_menuView.scrollView setContentOffset:offset animated:NO];
            
            indicatorUpdateRatio = indicatorUpdateRatio * 1;
            [_menuView setIndicatorViewFrameWithRatio:indicatorUpdateRatio isNextItem:isToNextItem toIndex:self.currentIndex];
        } else {
            
            CGPoint offset = _menuView.scrollView.contentOffset;
            offset.x = currentItemOffsetX - (nextItemOffsetX - currentItemOffsetX) * ratio;
            [_menuView.scrollView setContentOffset:offset animated:NO];
            
            indicatorUpdateRatio = indicatorUpdateRatio * -1;
            [_menuView setIndicatorViewFrameWithRatio:indicatorUpdateRatio isNextItem:isToNextItem toIndex:targetIndex];
        }
    }
    [self.menuView.helpButton setBackgroundImage: [UIImage imageNamed:[_btnImages objectAtIndex:self.currentIndex]]  forState:UIControlStateNormal];
    [self.menuView.helpButton setTag:self.currentIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentIndex = scrollView.contentOffset.x / _contentScrollView.frame.size.width;
    
    if (currentIndex == self.currentIndex) { return; }
    self.currentIndex = currentIndex;
    [self.menuView.helpButton setBackgroundImage: [UIImage imageNamed:[_btnImages objectAtIndex:self.currentIndex]]  forState:UIControlStateNormal];
    [self.menuView.helpButton setTag:self.currentIndex];
    // item color
    [_menuView setItemTextColor:self.menuItemTitleColor
           seletedItemTextColor:self.menuItemSelectedTitleColor
                   currentIndex:currentIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(containerViewItemIndex:currentController:)])
    {
        [self.delegate containerViewItemIndex:self.currentIndex currentController:_childControllers[self.currentIndex]];
    }
    [self setChildViewControllerWithCurrentIndex:self.currentIndex];
}

@end
