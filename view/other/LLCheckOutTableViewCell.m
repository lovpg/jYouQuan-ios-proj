//
//  LLCheckOutTableViewCell.m
//  Olla
//
//  Created by null on 14-10-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLCheckOutTableViewCell.h"

@implementation LLCheckOutTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.checkoutViewHidden = YES;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    self.checkoutViewHidden = YES;
}

- (void)setCheckoutViewHidden:(BOOL)checkoutViewHidden{
    
    _checkoutViewHidden = checkoutViewHidden;
    [self setNeedsDisplay];//这里记得刷新！！！
    
}

-(void)drawRect:(CGRect)rect{
    self.accessoryView = _checkoutViewHidden?nil:[self accessoryView];
}

- (UIView *)accessoryView{
    UIImageView *accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    accessoryImageView.image = [UIImage imageNamed:@"cell_checkout"];
    return accessoryImageView;
}


@end

