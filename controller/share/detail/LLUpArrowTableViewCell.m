//
//  LLUpArrowTableViewCell.m
//  Olla
//
//  Created by Charles on 15/7/27.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLUpArrowTableViewCell.h"

@implementation LLUpArrowTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 10, 14, 10)];
        _arrowImageView.image = [UIImage imageNamed:@"olla__dialogue_triangle"];
        [self addSubview:_arrowImageView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = RGB_DECIMAL(247, 247, 247);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
