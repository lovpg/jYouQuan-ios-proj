//
//  OllaLoadingMoreView.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-17.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaLoadingMoreView.h"

@implementation OllaLoadingMoreView

@synthesize textLabel = _textLabel;
@synthesize indicatorView = _indicatorView;
@synthesize isLoading = _isLoading;
@synthesize hasMoreData = _hasMoreData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startLoading{

    self.isLoading = YES;
    [self.indicatorView setHidden:NO];
    [self.indicatorView startAnimating];
}


- (void)stopLoading{
    self.isLoading = NO;
    [self.indicatorView stopAnimating];
}

- (void)setHasMoreData:(BOOL)hasMoreData{
    _hasMoreData = hasMoreData;
    if (!_hasMoreData) {// no more data
        [self.textLabel setText:@"no more data"];
        self.textLabel.center = self.center;
        [self.textLabel setHidden:NO];
        [self.indicatorView setHidden:YES];
    }else{
        
        [self.textLabel setText:@"loading more..."];
        [self.textLabel setHidden:NO];
        self.textLabel.originX =120;
        self.indicatorView.center = CGPointMake(120.f, CGRectGetHeight(self.bounds)/2);
        self.textLabel.originY = self.indicatorView.originY - 10;
        [self.indicatorView setHidden:NO];
    }
    
}

@end
