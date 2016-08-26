//
//  LLMyCenterHeadTableViewCell.m
//  Olla
//
//  Created by Charles on 15/8/14.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLMyCenterHeadTableViewCell.h"
//#import "LLMyFansViewController.h"
@implementation LLMyCenterHeadTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}




- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nicknameLabel.text = self.user.nickname;
    self.followCountLabel.text = self.user.followCount;
    self.fansCountLabel.text = self.user.fansCount;
    self.genderImageView.gender = self.user.gender;
    self.countryImageView.region = self.user.region;
    
    self.countryNameLabel.text = self.user.region;
    self.countryNameLabel.cornerRadius = 10.f;
    
    self.settingButton1.hidden = NO;
    self.settingButton2.backgroundColor = [UIColor clearColor];
    
    self.recordButton.hidden = NO;
    
    [self.avatarButton sd_setBackgroundImageWithURL:[NSURL URLWithString:self.user.avatar]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default_128"]];
    self.avatarButton.cornerRadius = self.avatarButton.height / 2.f;
    
    self.signLabel.text = self.user.sign;
    
    if (self.user.cover.length) {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.user.cover] placeholderImage:[UIImage imageNamed:@"default_friends_timeline_cover"]];
    } else {
        [self.coverImageView setImage:[UIImage imageNamed:@"default_friends_timeline_cover"]];
    }
//    
//    BOOL isEmail = NO;
//    BOOL isBirth = NO;
//    isEmail = [[[OllaPreference shareInstance] valueForKey:@"isEmail"] boolValue];
//    isBirth = [[[OllaPreference shareInstance] valueForKey:@"isBirth"] boolValue];
//    
//    if (isEmail && isBirth) {
//        // 隐藏红点
//        self.redPointImageView.hidden = YES;
//    } else {
//        // 显示红点
//        self.redPointImageView.hidden = NO;
//    }
//    
//    if (self.hideSettingAndFlag) {
//        self.settingButton1.hidden = self.hideSettingAndFlag;
//        self.flagButton.hidden = self.hideSettingAndFlag;
//    }
    
    
    // 隐藏来作暂时移除
    self.redPointImageView.hidden = YES;
    self.settingButton1.hidden = YES;
    
    //获取所有的friends
//    NSArray *array=[LLUser myFriends];
//    NSUInteger freindCount=array.count;
//    self.followCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)freindCount];
    //获取所有的fans hui shan


//        __weak __block typeof(self) weakSelf = self;
//        self.fansLabel.text=@"";
//       [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Groupbar_Auth parameters:nil modelType:[LLGroupBarAuth class] needCache:YES success:^(OllaModel *model) {
//           weakSelf.groupBarAuth=(LLGroupBarAuth*)model;
//           self.fansLabel.text=[NSString stringWithFormat:@"%ld",(long)self.groupBarAuth.fansCount];
//       } failure:^(NSError *error) {
//           
//       }];

    
#pragma mark - just for test hui shan
    //获取所有的fans
//    NSArray *fansArr=[LLUser myFans];
//    self.fansLabel.text=[NSString stringWithFormat:@"%d",fansArr.count];
    
    
}


- (IBAction)avatarButtonClick:(id)sender {
    [self routerEventWithName:LLMyCenterAvatarButtonClickEvent userInfo:nil];
}

- (IBAction)settingButtonClick:(id)sender {
    [self routerEventWithName:LLMyCenterSettingButtonClickEvent userInfo:nil];
}

- (IBAction)flagButtonClick:(id)sender {
    [self routerEventWithName:LLMyCenterFlagButtonClickEvent userInfo:nil];
}

- (IBAction)recordButtonClick:(UIButton *)sender {
    [self routerEventWithName:LLMyCenterRecordButtonClickEvent userInfo:@{@"recordButton":sender}];
}
//
//- (IBAction)playRecordButtonClick:(LLAudioPlayAnimationButton *)sender {
//    [self routerEventWithName:LLMyCenterPlayRecordButtonClickEvent userInfo:@{@"playRecordButton":sender}];
//}

- (IBAction)coverChangeButtonClick:(id)sender {
    [self routerEventWithName:LLMyCenterCoverChangeButtonClickEvent userInfo:nil];
}

- (IBAction)coinButtonClick:(id)sender {
    [self routerEventWithName:LLMyCenterCoinButtonClickEvent userInfo:nil];
}
- (IBAction)favoriteButtonClick:(id)sender {
    [self routerEventWithName:LLMyCenterFavoriteChangeButtonClickEvent userInfo:nil];
}


- (void)hideSettingButton:(BOOL)isTrue1 andFlagView:(BOOL)isTrue2 {
    
    self.settingButton1.hidden = isTrue1;
    self.flagButton.hidden = isTrue2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
