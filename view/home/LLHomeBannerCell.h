//
//  LLHomeBannerCell.h
//  jishou
//
//  Created by Reco on 16/7/21.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *LLScrollBannerButtonClickEvent = @"LLScrollBannerButtonClickEvent";


@interface LLHomeBannerCell : UITableViewCell<UIScrollViewDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;


@end
