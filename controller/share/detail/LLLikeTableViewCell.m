//
//  LLLikeTableViewCell.m
//  Olla
//
//  Created by Charles on 15/4/27.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLLikeTableViewCell.h"
#import "UIImageView+AFNetworking.h"

#define avatarRadius 20

@implementation LLLikeTableViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
 
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code

    
//    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, CGRectGetWidth(self.subviews), <#CGFloat height#>)];
//    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 给backgroundView添加约束
    // 前边
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:5]];
//    // 后边
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-5]];
//    // 高度
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:55]];
//    // 上边
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    

//    backgroundView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0f];
//    self.backgroundView = backgroundView;
//    
//    // 添加一个分割线
//    UIView *separateLine = [[UIView alloc] init];
//    separateLine.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    // 给SeparateLine添加约束
//    // 前边
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:separateLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:5]];
//    // 后边
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:separateLine attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-5]];
//    // 高度
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:separateLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1]];
//    // 下边
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:separateLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
//    
//    separateLine.backgroundColor = [UIColor whiteColor];
//    [self addSubview:separateLine];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.rectCorner = UIRectCornerTopLeft | UIRectCornerTopRight;
    self.cornerRadius = 10.f;
    
    // 添加一个背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, CGRectGetWidth(self.superview.frame) - 10, 59)];
    backgroundView.backgroundColor = RGB_HEX(0xededed);
    self.backgroundView = backgroundView;
    
//    // 添加一个分割线
//    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(5, 54, CGRectGetWidth(self.superview.frame) - 10, 1)];
//    separateLine.backgroundColor = [UIColor whiteColor];
//    [self addSubview:separateLine];

    if (self.likeArr.count <= 5) {
        
        for (int i = 0; i < self.likeArr.count; i++) {
            switch (i) {
                case 0:
                {
                    self.likeAvatar1.hidden = NO;
                    
                    LLLike *like = [self.likeArr objectAtIndex:i];
                    if ([like.avatar isKindOfClass:[NSNull class]]) {
                        like.avatar = @"headphoto_default_128";
                    }
                    [self.likeAvatar1 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
                    self.likeAvatar1.layer.cornerRadius = avatarRadius;
                    self.likeAvatar1.layer.masksToBounds = YES;
                    
                    break;
                }
                case 1:
                {
                    self.likeAvatar2.hidden = NO;
                    
                    LLLike *like = [self.likeArr objectAtIndex:i];
                    if ([like.avatar isKindOfClass:[NSNull class]]) {
                        like.avatar = @"headphoto_default_128";
                    }
                    [self.likeAvatar2 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
                    self.likeAvatar2.layer.cornerRadius = avatarRadius;
                    self.likeAvatar2.layer.masksToBounds = YES;
                    break;
                }
                case 2:
                {
                    self.likeAvatar3.hidden = NO;
                    
                    LLLike *like = [self.likeArr objectAtIndex:i];
                    if ([like.avatar isKindOfClass:[NSNull class]]) {
                        like.avatar = @"headphoto_default_128";
                    }
                    [self.likeAvatar3 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
                    self.likeAvatar3.layer.cornerRadius = avatarRadius;
                    self.likeAvatar3.layer.masksToBounds = YES;
                    break;
                }
                case 3:
                {
                    self.likeAvatar4.hidden = NO;
                    
                    LLLike *like = [self.likeArr objectAtIndex:i];
                    if ([like.avatar isKindOfClass:[NSNull class]]) {
                        like.avatar = @"headphoto_default_128";
                    }
                    [self.likeAvatar4 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
                    self.likeAvatar4.layer.cornerRadius = avatarRadius;
                    self.likeAvatar4.layer.masksToBounds = YES;
                    break;
                }
                case 4:
                {
                    self.likeAvatar5.hidden = NO;
                    
                    LLLike *like = [self.likeArr objectAtIndex:i];
                    if ([like.avatar isKindOfClass:[NSNull class]]) {
                        like.avatar = @"headphoto_default_128";
                    }
                    [self.likeAvatar5 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
                    self.likeAvatar5.layer.cornerRadius = avatarRadius;
                    self.likeAvatar5.layer.masksToBounds = YES;
                    break;
                }
                default:
                    
                    
                    break;
            }
            
        }
        
    } else {
        NSLog(@"do nothing now");
        
        self.likeAvatar1.hidden = NO;
        self.likeAvatar2.hidden = NO;
        self.likeAvatar3.hidden = NO;
        self.likeAvatar4.hidden = NO;
        self.likeAvatar5.hidden = NO;
        
        LLLike *like = [self.likeArr objectAtIndex:0];
        if ([like.avatar isKindOfClass:[NSNull class]]) {
            like.avatar = @"headphoto_default_128";
        }
        [self.likeAvatar1 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
        self.likeAvatar1.layer.cornerRadius = avatarRadius;
        self.likeAvatar1.layer.masksToBounds = YES;
        
        like = [self.likeArr objectAtIndex:1];
        if ([like.avatar isKindOfClass:[NSNull class]]) {
            like.avatar = @"headphoto_default_128";
        }
        [self.likeAvatar2 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
        self.likeAvatar2.layer.cornerRadius = avatarRadius;
        self.likeAvatar2.layer.masksToBounds = YES;
        
        like = [self.likeArr objectAtIndex:2];
        if ([like.avatar isKindOfClass:[NSNull class]]) {
            like.avatar = @"headphoto_default_128";
        }
        [self.likeAvatar3 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
        self.likeAvatar3.layer.cornerRadius = avatarRadius;
        self.likeAvatar3.layer.masksToBounds = YES;
        
        like = [self.likeArr objectAtIndex:3];
        if ([like.avatar isKindOfClass:[NSNull class]]) {
            like.avatar = @"headphoto_default_128";
        }
        [self.likeAvatar4 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
        self.likeAvatar4.layer.cornerRadius = avatarRadius;
        self.likeAvatar4.layer.masksToBounds = YES;
        
        like = [self.likeArr objectAtIndex:4];
        if ([like.avatar isKindOfClass:[NSNull class]]) {
            like.avatar = @"headphoto_default_128";
        }
        [self.likeAvatar5 sd_setImageWithURL:[NSURL URLWithString:like.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
        self.likeAvatar5.layer.cornerRadius = avatarRadius;
        self.likeAvatar5.layer.masksToBounds = YES;
    }
}

- (IBAction)avatarButtonClick:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
//        case 0:
//        {
//            LLLike *like = self.likeArr[0];
//            
//            if (!like.user) {
//                return;
//            }
//            
//            [self routerEventWithName:LLLikeAvatarButtonClickEvent1 userInfo:@{
//                                                                                @"avatar1":like.user}];
//        }
//            break;
//        case 1:
//        {
//            LLLike *like = self.likeArr[1];
//            
//            if (!like.user) {
//                return;
//            }
//            
//            [self routerEventWithName:LLLikeAvatarButtonClickEvent2 userInfo:@{
//                                                                               @"avatar2":like.user}];
//        }
//            break;
//        case 2:
//        {
//            LLLike *like = self.likeArr[2];
//            
//            if (!like.user) {
//                return;
//            }
//            
//            [self routerEventWithName:LLLikeAvatarButtonClickEvent3 userInfo:@{
//                                                                               @"avatar3":like.user}];
//        }
//            break;
//        case 3:
//        {
//            LLLike *like = self.likeArr[3];
//            
//            if (!like.user) {
//                return;
//            }
//            
//            [self routerEventWithName:LLLikeAvatarButtonClickEvent4 userInfo:@{
//                                                                               @"avatar4":like.user}];
//        }
//            break;
//        case 4:
//        {
//            LLLike *like = self.likeArr[4];
//            
//            if (!like.user) {
//                return;
//            }
//            
//            [self routerEventWithName:LLLikeAvatarButtonClickEvent5 userInfo:@{
//                                                                               @"avatar5":like.user}];
//        }
//            break;
//            
//        default:
//            break;
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self roundingCorners:self.rectCorner cornerRadius:self.cornerRadius];
}

@end
