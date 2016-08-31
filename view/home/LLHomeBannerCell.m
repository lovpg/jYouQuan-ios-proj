//
//  LLHomeBannerCell.m
//  jishou
//
//  Created by Reco on 16/7/21.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLHomeBannerCell.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height//获取屏幕高度，兼容性测试
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width//获取屏幕宽度，兼容性测试

@implementation LLHomeBannerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)ScrollClickAction:(id)sender
{
    NSLog(@"%ld",(long)self.pageControl.currentPage);
    NSLog(@"%ld",(long)self.pageControl.currentPage);
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"config"
                                                          ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *bannerMapping = data[@"banner-url-mapping"];
    NSNumber *currentPage  = [NSNumber numberWithInteger:self.pageControl.currentPage];
    NSString *shareId = nil;
    switch (currentPage.integerValue)
    {
        case 0:
            shareId = [bannerMapping objectForKey:@"banner-1"];
            break;
        case 1:
            shareId = [bannerMapping objectForKey:@"banner-2"];
            break;
        case 2:
            shareId = [bannerMapping objectForKey:@"banner-3"];
            break;
        default:
            break;
    }
    
    if(!shareId) return;
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Share_Detail parameters:@{@"shareId":shareId}
                                                   modelType:[LLShare class]
                                                     success:^(OllaModel *model)
     {
         LLShare *share = (LLShare *)model;
         NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[share dictionaryRepresentation]];
         [dict setValue:@(1) forKey:@"flag"];
         [dict setValue:share.user.uid forKey:@"uid"];
         [dict setValue:share.user.avatar forKey:@"avatar"];
         [dict setValue:share.user.gender forKey:@"gender"];
         [dict setValue:share.user.nickname forKey:@"nickname"];
         [self routerEventWithName:LLScrollBannerButtonClickEvent userInfo:@{@"share":share}];
     }
                                                     failure:^(NSError *error)
     {
         
     }];
    

}



- (void)layoutSubviews
{
    [super layoutSubviews];
    [self loadScrollData];
}

- (void)loadScrollData
{
    CGFloat imageW = self.bannerScrollView.frame.size.width;
    CGFloat imageH = self.bannerScrollView.frame.size.height;
    CGFloat imageY = 0;
    NSInteger totalCount = 3;
    for (int i = 0; i < totalCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        CGFloat imageX = i * imageW;
        imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        NSString *name = [NSString stringWithFormat:@"img_0%d", i + 1];
        imageView.image = [UIImage imageNamed:name];
        self.bannerScrollView.showsHorizontalScrollIndicator = NO;
        imageView.userInteractionEnabled=YES; 
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                  action:@selector(ScrollClickAction:)];
        [imageView addGestureRecognizer:tapGesture];
        [self.bannerScrollView addSubview:imageView];
    }
    CGFloat contentW = totalCount *imageW;
    self.bannerScrollView.contentSize = CGSizeMake(contentW, 0);
    self.bannerScrollView.pagingEnabled = YES;
    self.bannerScrollView.delegate = self;
    [self addTimer];
}

- (void)nextImage
{
    int page = (int)self.pageControl.currentPage;
    if (page == 2)
    {
        page = 0;
    }
    else
    {
        page++;
    }
    CGFloat x = page * self.bannerScrollView.frame.size.width;
    self.bannerScrollView.contentOffset = CGPointMake(x, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollviewW =  scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    int page = (x + scrollviewW / 2) /  scrollviewW;
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

- (void)addTimer
{
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10
                                                  target:self
                                                selector:@selector(nextImage)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)removeTimer
{
    [self.timer invalidate];
}

@end
