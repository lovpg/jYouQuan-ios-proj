//
//  LLLikeTableViewCell.h
//  Olla
//
//  Created by Charles on 15/4/27.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLLike.h"

static NSString *LLLikeAvatarButtonClickEvent1 = @"LLLikeAvatarButtonClickEvent1";
static NSString *LLLikeAvatarButtonClickEvent2 = @"LLLikeAvatarButtonClickEvent2";
static NSString *LLLikeAvatarButtonClickEvent3 = @"LLLikeAvatarButtonClickEvent3";
static NSString *LLLikeAvatarButtonClickEvent4 = @"LLLikeAvatarButtonClickEvent4";
static NSString *LLLikeAvatarButtonClickEvent5 = @"LLLikeAvatarButtonClickEvent5";

@interface LLLikeTableViewCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *likeArr;
@property (weak, nonatomic) IBOutlet UIButton *jumpTo;

@property (weak, nonatomic) IBOutlet UIButton *likeAvatar1;
@property (weak, nonatomic) IBOutlet UIButton *likeAvatar2;
@property (weak, nonatomic) IBOutlet UIButton *likeAvatar3;
@property (weak, nonatomic) IBOutlet UIButton *likeAvatar4;
@property (weak, nonatomic) IBOutlet UIButton *likeAvatar5;

@property (strong, nonatomic) UIImageView *tempImageView;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UIView *backGroundView;

//@property (nonatomic, strong) UIButton *btn;

// ***
@property(nonatomic,assign) UIRectCorner rectCorner;
@property(nonatomic,assign) CGFloat cornerRadius;
// ***

@end
