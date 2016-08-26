//
//  LLLoadingView.m
//  Olla
//
//  Created by Pat on 15/5/26.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLLoadingView.h"

@interface LLLoadingView () {
    UIActivityIndicatorView *indicatorView;
//    UILabel *self._statusLabel;
}

@end

@implementation LLLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _statusLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.text = @"看官，方圆十里已扫荡完毕.";
        _statusLabel.hidden = YES;
        [self addSubview:_statusLabel];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = CGPointMake(self.width / 2, self.height / 2);
        [indicatorView stopAnimating];
        indicatorView.hidesWhenStopped = YES;
        [self addSubview:indicatorView];
        
        self.page = 1;
        self.size = 20;
    }
    return self;
}

- (void)setHasNext:(BOOL)hasNext {
    _hasNext = hasNext;
    if (hasNext) {
        _statusLabel.hidden = YES;
    } else {
        _statusLabel.hidden = NO;
    }
}

- (void)startLoading {
    _statusLabel.hidden = YES;

    [indicatorView startAnimating];
}

- (void)stopLoading {

    _statusLabel.hidden = NO;

    [indicatorView stopAnimating];
}

- (BOOL)isLoading {
    return indicatorView.isAnimating;
}

@end
