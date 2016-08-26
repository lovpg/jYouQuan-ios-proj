//
//  LLCrownGoodCell.m
//  Olla
//
//  Created by Pat on 15/4/28.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLCrownGoodCell.h"
#import "UIResponder+Router.h"

@interface LLCrownGoodCell () {
    UIView *backView;
    UILabel *countLabel;
    NSArray *buttons;
}

@end

@implementation LLCrownGoodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.width - 20, 44)];
        backView.backgroundColor = RGB_DECIMAL(234, 234, 234);
        [self.contentView addSubview:backView];
        
        UIButton *goodButton = [[UIButton alloc] initWithFrame:CGRectMake(25, 10, 20, 20)];
        [goodButton setImage:[UIImage imageNamed:@"profile_crown_good"] forState:UIControlStateNormal];
        [goodButton addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:goodButton];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, goodButton.bottom, 40, 20)];
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.font = [UIFont systemFontOfSize:12];
        countLabel.textColor = [UIColor lightGrayColor];
        
        [self addSubview:countLabel];
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<5; i++) {
            UIButton *button = [[UIButton alloc] init];
            button.tag = i;
            [button addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
            [array addObject:button];
        }
        buttons = array;
    }
    return self;
}

- (void)setGoodList:(NSArray *)goodList {
    _goodList = goodList;
    
    if (goodList.count == 0) {
        countLabel.text = nil;
    } else {
        countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)goodList.count];
        
        for (UIImageView *imageView in buttons) {
            [imageView removeFromSuperview];
        }
        
        for (int i=0; i<goodList.count; i++) {
            LLSimpleUser *user = goodList[i];
            NSURL *url = [NSURL URLWithString:user.avatar];
            UIButton *button = buttons[i];
            button.frame = CGRectMake(55 + i * 50, 7, 40, 40);
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 20;
            [button sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
            [self.contentView addSubview:button];
            if (i==4) {
                break;
            }
        }
    }
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    backView.frame = CGRectMake(5, 0, self.width - 10, self.height);
}

- (void)like:(id)sender {
    [self routerEventWithName:CrownGoodButtonClickEvent userInfo:nil];
}

- (void)avatarClick:(UIButton *)button {
    LLSimpleUser *user = [self.goodList objectAtIndex:button.tag];
    [self routerEventWithName:CrownAvatorButtonClickEvent userInfo:@{@"user":user}];
}

@end
