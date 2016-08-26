//
//  LLDialogView.h
//  Olla
//
//  Created by null on 14-10-17.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLDialogView : UIView{
    
    UIButton *maskButton;
}

@property(nonatomic,strong) UIImageView *backgroundImageView;
@property(nonatomic,strong) UIColor *backgroundColor;
@property(nonatomic,strong) UIView *customView;

- (void)show:(BOOL)animated;
- (void)dismiss;

@end
