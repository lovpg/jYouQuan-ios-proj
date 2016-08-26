//
//  OllaTablePageController.m
//  OllaFramework
//
//  Created by null on 14-9-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaTablePageController.h"

@implementation OllaTablePageController

- (id)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.refreshViewEnable = YES;
    self.pageEnabled = YES;
    return self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.3];
}

- (void)startLoading{
    [super startLoading];
    [self.topRefreshView beginRefreshing];
    //bug:ODRefreshControl在iOS7，navigation管理的tableview时，存在44px偏移
}

- (void)stopLoading{
    
    [super stopLoading];
    
    if ([self.dataSource respondsToSelector:@selector(hasMoreData)]) {
        self.bottomLoadingView.hasMoreData = [(OllaPageDataSource *)self.dataSource hasMoreData];
    }
    
    [self.bottomLoadingView stopLoading];
    [self.topRefreshView endRefreshing];
}


-(UIControl<IOllaLoadingView> *)topRefreshView{
    
    if (!self.refreshViewEnable) {
        return nil;
    }
    
    if (!_topRefreshView) {
        _topRefreshView = [[OllaRefreshView alloc] initInScrollView:self.tableView];
        [_topRefreshView addTarget:self action:@selector(tableViewRefreshTrigger:) forControlEvents:UIControlEventValueChanged];
    }
    return _topRefreshView;
}

// 空
- (void)tableViewRefreshTrigger:(UIControl<IOllaLoadingView> *)refreshView{
    NSLog(@"refresh trigger");
    [self refreshData];
}

// to be overwrite
- (void)tableViewHaveScrollToBottom{

}


-(UITableViewCell<IOllaLoadingMoreView> *)bottomLoadingView{
    if (!_bottomLoadingView) {// xib 中没有配置，使用代码配置
        
        _bottomLoadingView = [[OllaLoadingMoreView  alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        _bottomLoadingView.backgroundColor = [UIColor clearColor];
        _bottomLoadingView.selectionStyle = UITableViewCellSelectionStyleNone;
        _bottomLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.center = _bottomLoadingView.center;
        indicatorView.autoresizingMask = UIViewAutoresizingNone;
        _bottomLoadingView.indicatorView = indicatorView;
        [_bottomLoadingView addSubview:indicatorView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        textLabel.center = _bottomLoadingView.center;
        indicatorView.autoresizingMask = UIViewAutoresizingNone;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont systemFontOfSize:13.f];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLoadingView.textLabel = textLabel;
        [_bottomLoadingView addSubview:textLabel];
        
        
    }
    return _bottomLoadingView;
}


//tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // 如果[datasource count]为空,就不算middleCells
    NSUInteger dataSourceCount = [self.dataSource count];
    //    if (!dataSourceCount) {
    //        return [_headerCells count];
    //    }
    return [self.headerCells count]+ dataSourceCount + 1;// loadingMore
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == [self.headerCells count]+ [self.dataSource count] ) {// loadingMore
        return self.bottomLoadingView.frame.size.height;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([self addBottomLoadingViewAtIndexPath:indexPath]) {//bottom more
        return self.bottomLoadingView;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (BOOL)addBottomLoadingViewAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == [self.headerCells count]+ [self.dataSource count]) {
        return YES;
    }
    
    return NO;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == [self.headerCells count] + [self.dataSource count]) {
        return ;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (cell == self.bottomLoadingView) {
        
        if (![(OllaPageDataSource *)self.dataSource hasMoreData]) {
            [self tableViewHaveScrollToBottom];
            return;
        }
        
        if ( self.pageEnabled &&
            ![self.bottomLoadingView isLoading] &&
            [(OllaPageDataSource *)self.dataSource hasMoreData] &&
            ![self.dataSource isLoading]) {
            
            [self.bottomLoadingView startLoading];
            
            if ([self.dataSource respondsToSelector:@selector(loadMoreData)]) {
                [self.dataSource performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.5f];
            }
        }
        
    }
    
}


@end
