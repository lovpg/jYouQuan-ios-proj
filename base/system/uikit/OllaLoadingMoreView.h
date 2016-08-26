//
//  OllaLoadingMoreView.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-17.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol IOllaLoadingMoreView <NSObject>

@property(nonatomic,weak) IBOutlet UILabel *textLabel;
@property(nonatomic,weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property(nonatomic,assign) BOOL isLoading;
@property(nonatomic,assign) BOOL hasMoreData;

- (void)startLoading;
- (void)stopLoading;


@end

//TODO:7
@interface OllaLoadingMoreView : UITableViewCell<IOllaLoadingMoreView>

@end
