//
//  OllaImageLimitGridView.h
//  OllaFramework
//
//  Created by nonstriater on 14-8-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString  *OllaLimitGridViewSelecteItemNotification;
@protocol OllaImageLimitGridViewDelegate;


//用于展示少量的图片（1~20张图片左右）, 可以是网络url
@interface OllaImageLimitGridView : UIView

@property(nonatomic,assign) int numberOfButtonPerRow;

@property(nonatomic,strong)  IBOutletCollection(UIButton) NSArray *imageButtons;
@property(nonatomic,strong) IBOutlet UIImageView *backgroundImageView;
@property(nonatomic,strong) IBOutlet id<OllaImageLimitGridViewDelegate> delegate;

@property(nonatomic,assign) CGSize cellSize;

@property(nonatomic,strong) NSArray *images; // 有几张图片
@property(nonatomic,strong) NSArray *thumbImages; 
@property(nonatomic,assign) CGFloat cellImageCornerRadius;

@property(nonatomic,assign) BOOL enableNotification;

+ (CGFloat)heightWhenImagesCount:(int)count imageSize:(CGSize)size;// 方便cell计算高度，做动态排版
- (IBAction)imageButtonClicked:(id)sender;
- (void)cancelAllImageLoading;

@end


@protocol OllaImageLimitGridViewDelegate <NSObject>
@optional
- (void)imageLimitGridView:(OllaImageLimitGridView *)gridView didSelectedAtIndex:(NSInteger)index;

@end


