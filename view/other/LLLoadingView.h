//
//  LLLoadingView.h
//  Olla
//
//  Created by Pat on 15/5/26.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLLoadingView : UIView

@property (nonatomic, assign) int page;
@property (nonatomic, assign) int size;
@property (nonatomic, assign) BOOL hasNext;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) UILabel *statusLabel;

- (void)startLoading;
- (void)stopLoading;

@end
