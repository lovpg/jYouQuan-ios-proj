//
//  OllaImageLimitGridView.m
//  OllaFramework
//
//  Created by nonstriater on 14-8-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaImageLimitGridView.h"

NSString const *OllaLimitGridViewSelecteItemNotification = @"OllaLimitGridViewSelecteItemNotification";

const NSInteger tagOffset = 100;

const CGFloat imageButtonWidth_default = 80.f;
const CGFloat imageButtonHeight_default = 80.f;
const NSInteger numberOfButtonPerRow_default = 2;
const CGFloat imageMargin = 5.f;
// 一行排3个，gridview的宽度应该是：3*80+2*4 = 248
// 高度= row*80+(row+1)*2



@implementation OllaImageLimitGridView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib{

    [self commonInit];
}


- (void)commonInit{

    self.enableNotification = YES;
    self.numberOfButtonPerRow = numberOfButtonPerRow_default;
    self.cellSize = CGSizeMake(imageButtonWidth_default, imageButtonHeight_default);
    
}


- (void)setImages:(NSArray *)images{
    
    if (_images == images && _images!=nil) {
        return;
    }
    
    _images = images;
    [self setNeedsLayout]; // call layoutSubviews at next update
    //[self layoutIfNeeded]; // update immediately, 这里没有触发-layoutSubviews
    
}


- (void)drawRect:(CGRect)rect{
    
    if (self.cellImageCornerRadius) {
        self.layer.cornerRadius = self.cellImageCornerRadius;
    }
}

- (void)layoutSubviews{
    
    if ([self.images count]) {
        
        for (int i=0; i<[self.images count]; i++) {
            [self setButtonWithImage:self.images[i] atIndex:i];
        }
        
        NSInteger row = ([self.images count]-1)/self.numberOfButtonPerRow+1;
        self.height = row*(_cellSize.height)+(row+1)*imageMargin;
        
        NSInteger numberOfButtonInRow = MIN([self.images count], self.numberOfButtonPerRow);
        self.width = numberOfButtonInRow*(_cellSize.width)+(numberOfButtonInRow+1)*imageMargin;
    }
 
}


- (void)setButtonWithImage:(id)image atIndex:(NSInteger)index{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.cellImageCornerRadius) {
        button.cornerRadius = self.cellImageCornerRadius;
        button.clipsToBounds = YES;
    }
    button.contentMode = UIViewContentModeScaleAspectFill;
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    for(UIView *view in button.subviews) {
        view.contentMode = UIViewContentModeScaleAspectFill;
    }
    [button addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    button.tag = tagOffset + index;
    
    NSInteger row = index/self.numberOfButtonPerRow;
    NSInteger coloum = index%self.numberOfButtonPerRow;
    
    [button setFrame:CGRectMake(
                                (coloum+1)*imageMargin+coloum*(_cellSize.width),
                                (row+1)*imageMargin+row*(_cellSize.width) , (_cellSize.width), (_cellSize.height))];
    [self addSubview:button];
    
    
    if ([image isKindOfClass:[UIImage class]]) {
        [button setImage:image forState:UIControlStateNormal];
    }else {// 网络
        [button setRemoteImageURL:image];
    }
    button.userInteractionEnabled = NO;
}


- (IBAction)imageButtonClicked:(id)sender{
    
    if (![sender isKindOfClass:[UIButton class]]) {
        return ;
    }

    //NSInteger index = [_imageButtons indexOfObject:sender];
    //根据sender坐标判断
    NSInteger index = [(UIButton *)sender tag]-tagOffset;
    
    
    if (index==NSNotFound) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(imagePickerGridView:didSelectedAtIndex:)]) {
        [_delegate imageLimitGridView:self didSelectedAtIndex:index];
    }
    
    if (self.enableNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaLimitGridViewSelecteItemNotification" object:self userInfo:@{@"selectedIndex":@(index)}];
    }
    
}


- (void)cancelAllImageLoading
{
    for (UIView *button in [self subviews]) {
        
        if ([button isKindOfClass:[UIButton class]]) {
            [(UIButton *)button sd_cancelImageLoadForState:UIControlStateNormal];
        }
        
    }
}

+ (CGFloat)heightWhenImagesCount:(int)count imageSize:(CGSize)size{
    
    int row = (count-1)/numberOfButtonPerRow_default+1;
    return row*size.height+(row+1)*imageMargin;
}


- (void)dealloc{
    [self cancelAllImageLoading];
}




@end
