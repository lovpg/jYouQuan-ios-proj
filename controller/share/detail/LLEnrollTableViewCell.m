//
//  LLEnrollTableViewCell.m
//  iDleChat
//
//  Created by Reco on 16/3/4.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "LLEnrollTableViewCell.h"
#import "AppDelegate.h"

@implementation LLEnrollTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        enrollButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 10, 120, 30)];
//        enrollButton.text = @"立即报名";
//        enrollButton.font = [UIFont systemFontOfSize: 14.0];
//        enrollButton.backgroundColor =  RGB_HEX(0x5fc225);

        enrollDetailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        enrollDetailButton.text = @"报名情况";
        enrollDetailButton.font = [UIFont systemFontOfSize: 14.0];
        enrollDetailButton.backgroundColor =  RGB_HEX(0x5fc225);
        [enrollDetailButton addTarget:self action:@selector(enrollButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        enrollDetailButton.center = self.center;
        enrollDetailButton.frame = [AppDelegate getFrame:enrollDetailButton.frame];
//        [self addSubview:enrollButton];
        [self addSubview:enrollDetailButton];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = RGB_DECIMAL(247, 247, 247);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
- (IBAction)enrollButtonClick:(id)sender
{
     [self routerEventWithName:LLEnrollDetailButtonClick userInfo:nil];
}

@end
