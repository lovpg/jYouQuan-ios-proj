//
//  LLNickNameTableViewCell.m
//  jYouQuan
//
//  Created by Corporal on 16/9/5.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLNickNameTableViewCell.h"

@implementation LLNickNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.nicknameLB.textColor = [UIColor lightGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
