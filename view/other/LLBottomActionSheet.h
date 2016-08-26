//
//  LLBottomActionSheet.h
//  Olla
//
//  Created by between_ios on 14-10-31.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//
@class LLBottomActionSheet;
@protocol LLBottomActionSheetDelegate <NSObject>
@optional
-(void)sheetSelecteButton:(NSInteger)buttonIndex sheetView:(LLBottomActionSheet *)sheetView;
@end
#import <UIKit/UIKit.h>

typedef enum
{
    SheetNormal = 1,
    SheetRedButton = 2
    
} sheetStyle;

@interface LLBottomActionSheet : UIView

#pragma mark 添加控件
@property (nonatomic ,weak) id<LLBottomActionSheetDelegate>delegate;
@property (nonatomic,assign) sheetStyle style;

@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) UIButton *maskButtonView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *confirmButton;

- (void)show;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitles:(NSString *)confirmButtonTitles;




@end
