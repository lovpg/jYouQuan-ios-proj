/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "FacialView.h"
#import "Emoji.h"
#import "FaceCollectionViewCell.h"
#import "FaceFlowLayout.h"

@interface FacialView () <UICollectionViewDelegate, UICollectionViewDataSource> {
    UICollectionView *emojiCollectionView;
    FaceFlowLayout *flowLayout;
    UIPageControl *pageControl;
    UIButton *sendButton;
}

@end

@implementation FacialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _faces = [Emoji allEmoji];
        
        flowLayout = [[FaceFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(frame.size.width / 7, 40.0f);
        emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 200)
                                                 collectionViewLayout:flowLayout];
        emojiCollectionView.delegate = self;
        emojiCollectionView.dataSource = self;
        emojiCollectionView.scrollsToTop = NO;
        emojiCollectionView.showsHorizontalScrollIndicator = NO;
        emojiCollectionView.showsVerticalScrollIndicator = NO;
        emojiCollectionView.scrollsToTop = NO;
        emojiCollectionView.scrollEnabled = YES;
        emojiCollectionView.pagingEnabled = YES;
        emojiCollectionView.delegate = self;
        emojiCollectionView.dataSource = self;
        emojiCollectionView.backgroundColor = [UIColor clearColor];
        [emojiCollectionView registerClass:[FaceCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
        
        [self addSubview:emojiCollectionView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 20.0f, frame.size.width, 20.0f)];
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageControl.numberOfPages = (int)ceil(_faces.count / 28)+1;
        pageControl.currentPage = 0;
        [self addSubview:pageControl];
        
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame = CGRectMake(frame.size.width - 60, frame.size.height - 32, 60, 32);
        [sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setTitleColor:RGB_DECIMAL(0, 91, 255) forState:UIControlStateNormal];
        [self addSubview:sendButton];
    }
    return self;
}

#pragma mark - UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger section = _faces.count / 4;
    
    while (section % 7 != 0) {
        section++;
    }
    
    return section;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceCollectionViewCell *cell = (FaceCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Emoji" forIndexPath:indexPath];
    NSString *emoji = [self emojiStringWithIndexPath:indexPath];
    [cell.button setTitle:emoji forState:UIControlStateNormal];
    if (!cell.targetAdd) {
        [cell.button addTarget:self action:@selector(emojiButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.targetAdd = YES;
    }
    return cell;
}

- (void)emojiButtonClick:(UIButton *)button {
    NSString *emoji = [button titleForState:UIControlStateNormal];
    if (emoji.length > 0) {
        if (_faceViewDelegate) {
            [_faceViewDelegate selectedFacialView:emoji];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat width = emojiCollectionView.width;
    int page = floor((emojiCollectionView.contentOffset.x - width / 2) / width) + 1;
    
    if (page != pageControl.currentPage) {
        pageControl.currentPage = page;
    }
}

// 获得数据源中对应的表情
- (NSString *)emojiStringWithIndexPath:(NSIndexPath *)indexPath {

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    int index =  (int)((int)floor(section / 7) * 28 + 7 * row + (section % 7));
    if (index < 0 || index > _faces.count - 1) {
        return nil;
    }
    
    return [_faces objectAtIndex:index];
}


//给faces设置位置
-(void)loadFacialView:(int)page size:(CGSize)size
{
	
}


- (void)sendButtonClick:(id)sender
{
    if (_faceViewDelegate) {
        [_faceViewDelegate sendFace];
    }
}

@end
