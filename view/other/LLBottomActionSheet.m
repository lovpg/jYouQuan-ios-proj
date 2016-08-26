//
//  LLBottomActionSheet.m
//  Olla
//
//  Created by between_ios on 14-10-31.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBottomActionSheet.h"

@implementation LLBottomActionSheet
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitial];
    }
    return self;
}

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitles:(NSString *)confirmButtonTitles
{
    if(self = [super init]){
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.titleLabel.text = title;
        self.delegate = delegate;
        self.cancelButton.text = cancelButtonTitle;
        self.confirmButton.text = confirmButtonTitles;
        
        self.style = SheetNormal;
        
    }
    return self;
}

- (void)awakeFromNib{
    
    [self commonInitial];
    
}

- (void)commonInitial{
    
    _maskButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _maskButtonView.backgroundColor = RGB_HEX(0x000000);
    _maskButtonView.alpha = 0.3f;
    [_maskButtonView addTarget:self action:@selector(maskButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_maskButtonView];
    
    
    _coverView = [[UIView alloc]init];
    if(IS_3_5){
    _coverView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height*0.6, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*0.4+20);
    }else {
              _coverView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height*0.6, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*0.4);
    }
    _coverView.backgroundColor = RGB_HEX(0x333333);
    _coverView.originY = Screen_Height;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            _coverView.originY = Screen_Height-CGRectGetHeight(_coverView.frame);
    }];
    _coverView.userInteractionEnabled = YES;
    [self addSubview: _coverView];
    
    
    _cancelButton = [[UIButton alloc]init];
    _cancelButton.layer.cornerRadius = 5;
    _cancelButton.backgroundColor = RGB_HEX(0x666666);
    _cancelButton.frame = CGRectMake(16, 128, 286, 50);
    _cancelButton.text = @"Cancel";
    _cancelButton.textColor = RGB_HEX(0xffffff);
    [_cancelButton addTarget:self action:@selector(touchupcancelButton) forControlEvents:UIControlEventTouchUpInside];
    [_coverView addSubview:_cancelButton];
    
    
    _confirmButton = [[UIButton alloc]init];
    _confirmButton.layer.cornerRadius = 5;
    _confirmButton.frame = CGRectMake(16, 60, 286, 50);
    _confirmButton.text = @"Yes";
    [_confirmButton addTarget:self action:@selector(touchupSelectedButton) forControlEvents:UIControlEventTouchUpInside];
    [_coverView addSubview:_confirmButton];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 30);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = RGB_HEX(0xffffff);
    [_coverView addSubview:_titleLabel];
    
    
}
-(void)setStyle:(sheetStyle)style
{
    switch (style) {
        case SheetNormal:
            self.confirmButton.backgroundColor = RGB_HEX(0xffffff);
            self.confirmButton.textColor = RGB_HEX(0x666666);
            break;
        case SheetRedButton:
            self.confirmButton.borderWidth = 0.5f;
            self.confirmButton.borderColor = RGB_HEX(0xe37474);
            self.confirmButton.backgroundColor = RGB_HEX(0xfd5f5f);
            self.confirmButton.textColor = RGB_HEX(0xffffff);
            break;
    }
}

#pragma mark 点击事件的处理
-(void)maskButton{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.coverView.originY = Screen_Height;
        self.maskButtonView.alpha = 0.f;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
    
}

#pragma mark 点确定传值执行操作
-(void)touchupSelectedButton
{
    
    [self.delegate sheetSelecteButton:1 sheetView:self];
    
}

-(void)touchupcancelButton
{
    
    [UIView animateWithDuration:0.4 animations:^{
        _coverView.originY = Screen_Height;
        self.maskButtonView.alpha = 0.f;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
    
}


-(void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (animated) {

        [UIView animateWithDuration:0.4 animations:^{
            self.coverView.originY = Screen_Height;
            self.maskButtonView.alpha = 0.f;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
        
    }else{
        
        [self removeFromSuperview];
        
    }
}

@end
