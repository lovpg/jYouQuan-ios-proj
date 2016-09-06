//
//  LLAvatorTableViewCell.m
//  jYouQuan
//
//  Created by Corporal on 16/9/5.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLAvatorTableViewCell.h"

@implementation LLAvatorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatorImage.layer.cornerRadius = 8;
    self.avatorImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
