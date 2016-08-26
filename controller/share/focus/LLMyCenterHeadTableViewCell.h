//
//  LLMyCenterHeadTableViewCell.h
//  Olla
//
//  Created by Charles on 15/8/14.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLGenderImageView.h"
#import "LLCountryImageView.h"
#import "LLCountryRemarkLabel.h"



static NSString *LLMyCenterAvatarButtonClickEvent = @"LLMyCenterAvatarButtonClickEvent";
static NSString *LLMyCenterCoverChangeButtonClickEvent = @"LLMyCenterCoverChangeButtonClickEvent";
static NSString *LLMyCenterFlagButtonClickEvent = @"LLMyCenterFlagButtonClickEvent";
static NSString *LLMyCenterRecordButtonClickEvent = @"LLMyCenterRecordButtonClickEvent";
static NSString *LLMyCenterPlayRecordButtonClickEvent = @"LLMyCenterPlayRecordButtonClickEvent";
static NSString *LLMyCenterSettingButtonClickEvent = @"LLMyCenterSettingButtonClickEvent";

static NSString *LLMyCenterCoinButtonClickEvent = @"LLMyCenterCoinButtonClickEvent";
static NSString *LLMyCenterFavoriteChangeButtonClickEvent=@"LLMyCenterFavoriteChangeButtonClickEvent";

@interface LLMyCenterHeadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *followCountLabel;
@property (strong, nonatomic) LLUser *user;

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet LLGenderImageView *genderImageView;
@property (weak, nonatomic) IBOutlet LLCountryImageView *countryImageView;
@property (weak, nonatomic) IBOutlet UIButton *settingButton1;

@property (weak, nonatomic) IBOutlet UIButton *settingButton2;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UIButton *flagButton;

@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *replaceCoverButton;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@property (weak, nonatomic) IBOutlet UIImageView *redPointImageView;
//粉丝数 关注数
@property (weak, nonatomic) IBOutlet UIImageView *followImageView;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fansImageView;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UIButton *fansBtn;

//wallet favorite
@property (weak, nonatomic) IBOutlet UIButton *walletButton;
@property (weak, nonatomic) IBOutlet UIImageView *walletImageView;
@property (weak, nonatomic) IBOutlet UILabel *walletLabel;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;
@property (weak, nonatomic) IBOutlet UILabel *favoriteLabel;

@property (nonatomic) BOOL hideSettingAndFlag;

@property (weak, nonatomic) IBOutlet LLCountryRemarkLabel *countryNameLabel;

- (void)hideSettingButton:(BOOL)isTrue1 andFlagView:(BOOL)isTrue2;

@end
