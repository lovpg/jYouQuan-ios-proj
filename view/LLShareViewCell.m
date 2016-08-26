//
//  LLShareViewCell.m
//  jishou
//
//  Created by Reco on 16/7/19.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLShareViewCell.h"

@implementation LLShareViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    NSLog(@"%@", self.dataItem);
    NSLog(@"%@", self.dataItem);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"%@", self.dataItem);
    nickname.text = self.dataItem;
}
@end
